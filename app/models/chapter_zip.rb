class ChapterZip < ApplicationRecord
  belongs_to :book_zip
  has_many :paragraph_matches,
    -> { order('position') },
     dependent: :destroy
  belongs_to :source_chapter, class_name: "Chapter"
  belongs_to :target_chapter, class_name: "Chapter"
  before_create :set_title, :set_end_positions
  before_validation :process_zip_info, if: Proc.new { |cz| cz.zip_info.present? }
  before_save :build_paragraph_matches
  serialize :zip_info, JSON


  def build_default_zip_info
    self.zip_info = {'source' => {'attach_ids' => []},
                 'target' => {'attach_ids' => []}
    }
    source_locs = get_locs(source_ps)
    target_locs = get_locs(target_ps)
    if source_locs.length > target_locs.length
      zip_info['source']['attach_ids'] = get_attach_idxs(
        source_locs, target_locs).map {|sip| source_ps[sip].id}
    else
      zip_info['target']['attach_ids'] = get_attach_idxs(
        target_locs, source_locs).map {|tip| target_ps[tip].id}
    end
  end

  def process_zip_info
    #turn string ids into int ids if necessary
    self.zip_info ||= {}
    for p in ['source', 'target']
      zip_info[p] ||= {}
      k = 'attach_ids'
      zip_info[p][k] ||= []
      zip_info[p][k] = zip_info[p][k].map(&:to_i)
    end
  end

  def ok_to_match(source_ps, target_ps)
    s_len = source_ps.count
    t_len = target_ps.count
    (t_len.to_f / s_len).between?(0.9, 1.1) || ((s_len - t_len).abs < 3)
  end

  def get_locs(ps)
    ps_ls = ps.map do |p|
      p.content.split().length
    end
    len_total = ps_ls.sum.to_f
    weights = ps_ls.map{|l| l/len_total}
    locs = [weights[0]/2.0]
    pos = [weights[0]]
    weights[1..].each do |w|
      locs.append(pos[-1] + w/2.0)
      pos.append(pos[-1] + w)
    end
    locs
  end

  def set_title
    self.title = source_chapter.title + ' - ' + target_chapter.title
  end

  def set_end_positions
    self.end_position_source ||= self.source_chapter.paragraphs.last.position
    self.end_position_target ||= self.target_chapter.paragraphs.last.position
  end

  def get_attach_idxs(loc_source, loc_target)
    # assuming loc_source.length > loc_target.length
    # output: [index of paragraphs thet should be attached to previn source]
    last_target_pos = 0
    target_source_diff = loc_source.length - loc_target.length
    res = []
    loc_source[1..].each_with_index do |loc, i|
      source_pos = i + 1
      if target_source_diff == 0
        return res
      elsif (last_target_pos == loc_target.length - 1)
        res.append(source_pos)
      else
        dist_to_t0 = (loc - loc_target[last_target_pos]).abs
        dist_to_t1 = (loc - loc_target[last_target_pos+1]).abs
        if dist_to_t0 < dist_to_t1
          res.append(source_pos)
          target_source_diff -= 1
        else
          last_target_pos += 1
        end
      end
    end
    res
  end

  def source_ps
    unless @source_ps
      @source_ps = source_chapter.paragraphs.where(
        "position >= ?", start_position_source).active
      if end_position_source
        @source_ps = @source_ps.where("position <= ?", end_position_source)
      end
      @source_ps = @source_ps.to_a
    end
    @source_ps
  end

  def target_ps
    unless @target_ps
      @target_ps = target_chapter.paragraphs.where(
        "position >= ?", start_position_target).active
      if end_position_target
        @target_ps = @target_ps.where("position <= ?", end_position_target)
      end
      @target_ps = @target_ps.to_a
    end
    @target_ps
  end

  def build_groupped_ps(ps, z_inf)
    ps[1..].reduce([[ps[0]]]) do |acc, p|
      if z_inf['attach_ids'].include?(p.id)
        acc[-1].append(p)
        acc
      else
        acc.append([p])
      end
    end
  end

  def build_paragraph_matches
    paragraph_matches.destroy_all
    build_default_zip_info unless zip_info
    groupped_source = build_groupped_ps(source_ps, zip_info['source'])
    groupped_target = build_groupped_ps(target_ps, zip_info['target'])
    # TODO: both length should be equal, check on validation
    pm_len = [groupped_source.length, groupped_target.length].min
    (0...pm_len).each do |pos|
        self.paragraph_matches.build(
          position: pos,
          source_start_position: groupped_source[pos][0].position,
          source_end_position: groupped_source[pos][-1].position,
          target_start_position: groupped_target[pos][0].position,
          target_end_position: groupped_target[pos][-1].position,
          chapter_zip: self
        )
    end
  end
end
