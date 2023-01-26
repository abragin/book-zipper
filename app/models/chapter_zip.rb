class ChapterZip < ApplicationRecord
  belongs_to :book_zip
  has_many :paragraph_matches,
    -> { order('position') },
     dependent: :destroy
  belongs_to :source_chapter, class_name: "Chapter"
  belongs_to :target_chapter, class_name: "Chapter"
  before_create :set_title, :set_end_positions
  before_validation :process_zip_info
  before_save :build_paragraph_matches
  serialize :zip_info, JSON


  def build_default_zip_info
    self.zip_info = {'source' => {'attach_ids' => []},
                 'target' => {'attach_ids' => []}
    }
    source_weights = get_weights(source_ps)
    target_weights = get_weights(target_ps)
    zipper = ChapterZipper.new(source_weights, target_weights)
    source_idx, target_idx = zipper.get_merge_idx
    zip_info['source']['attach_ids'] = source_idx.map {
      |sip| source_ps[sip].id
    }
    zip_info['target']['attach_ids'] = target_idx.map {
      |tip| target_ps[tip].id
    }
  end

  def next_chapter_zip
    if source_chapter.max_p_position == end_position_source
      next_s_chapter = book_zip.ebook_source.chapters.where(
        "position >  ?", source_chapter.position).order(:position).first
      next_s_position = 0
    else
      next_s_chapter = source_chapter
      next_s_position = end_position_source + 1
    end
    if target_chapter.max_p_position == end_position_target
      next_t_chapter = book_zip.ebook_target.chapters.where(
        "position >  ?", target_chapter.position).order(:position).first
      next_t_position = 0
    else
      next_t_chapter = target_chapter
      next_t_position = end_position_target + 1
    end
    if next_s_chapter && next_t_chapter
      ChapterZip.new(
        position: position + 1,
        source_chapter: next_s_chapter,
        target_chapter: next_t_chapter,
        start_position_source: next_s_position,
        start_position_target: next_t_position,
        book_zip: book_zip
      )
    else
      nil
    end
  end

  def get_updated_attach_ids(ps, attach_ids, cnt)
    res = []
    ps.reverse.each do |p|
      if attach_ids.exclude?(p.id)
        res.append(p.id)
      end
      if res.length == cnt
        return res
      end
    end
    return res
  end

  def process_zip_info
    if new_record?
      build_default_zip_info
    else
      self.zip_info ||= {}
    end
    #turn string ids into int ids if necessary
    for p in ['source', 'target']
      zip_info[p] ||= {}
      k = 'attach_ids'
      zip_info[p][k] ||= []
      zip_info[p][k] = zip_info[p][k].map(&:to_i)
    end
    # adding extra merge indexes to the end, if length mismatch is present
    res_source_len = self.source_ps.length - zip_info['source']['attach_ids'].length
    res_target_len = self.target_ps.length - zip_info['target']['attach_ids'].length
    if res_source_len > res_target_len
      zip_info['source']['attach_ids'] += get_updated_attach_ids(
        source_ps, zip_info['source']['attach_ids'],
        res_source_len - res_target_len
      )
    elsif res_target_len > res_source_len
      zip_info['target']['attach_ids'] += get_updated_attach_ids(
        target_ps, zip_info['target']['attach_ids'],
        res_target_len - res_source_len
      )
    end
  end

  def ok_to_match(source_ps, target_ps)
    s_len = source_ps.count
    t_len = target_ps.count
    (t_len.to_f / s_len).between?(0.9, 1.1) || ((s_len - t_len).abs < 3)
  end

  def get_weights(ps)
    ps_ls = ps.map do |p|
      p.content.split().length
    end
    len_total = ps_ls.sum.to_f
    ps_ls.map{|l| l/len_total}
  end

  def set_title
    self.title = source_chapter.title.strip + ' - ' + target_chapter.title.strip
  end

  def set_end_positions
    self.end_position_source ||= self.source_chapter.paragraphs.last.position
    self.end_position_target ||= self.target_chapter.paragraphs.last.position
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
    groupped_source = build_groupped_ps(source_ps, zip_info['source'])
    groupped_target = build_groupped_ps(target_ps, zip_info['target'])
    # TODO: both length should be equal, check on validation
    pm_len = [groupped_source.length, groupped_target.length].min
    (0...pm_len).each do |pos|
        self.paragraph_matches.build(
          position: pos,
          source_paragraphs: groupped_source[pos],
          target_paragraphs: groupped_target[pos],
          chapter_zip: self
        )
    end
  end
end
