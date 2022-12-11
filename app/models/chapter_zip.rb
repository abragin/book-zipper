class ChapterZip < ApplicationRecord
  belongs_to :book_zip
  has_many :paragraph_matches,
    -> { order('position') },
     dependent: :destroy
  belongs_to :source_chapter, class_name: "Chapter"
  belongs_to :target_chapter, class_name: "Chapter"
  before_create :set_title

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

  def get_zip_map(loc_source, loc_target)
    # assuming loc_source.length > loc_target.length
    # output: [[index of matching paragraph in source]] - for each target
    # (output length = loc_target length)
    last_target_pos = 0
    target_source_diff = loc_source.length - loc_target.length
    res_ = [last_target_pos]
    loc_source[1..].each do |loc|
      if target_source_diff == 0
        last_target_pos += 1
        res_.append(last_target_pos)
      elsif (last_target_pos == loc_target.length - 1)
        res_.append(last_target_pos)
        target_source_diff -= 1
      else
        dist_to_t0 = (loc - loc_target[last_target_pos]).abs
        dist_to_t1 = (loc - loc_target[last_target_pos+1]).abs
        if dist_to_t0 < dist_to_t1
          res_.append(last_target_pos)
          target_source_diff -= 1
        else
          last_target_pos += 1
          res_.append(last_target_pos)
        end
      end
    end
    res = []
    res_.each_with_index do |r, i|
      if res[r]
        res[r].append(i)
      else
        res.append([i])
      end
    end
    res
  end

  def source_ps
    res = source_chapter.paragraphs.where(
      "position >= ?", start_position_source)
    if end_position_source
      res = res.where("position <= ?", end_position_source)
    end
    res.to_a
  end

  def target_ps
    res = target_chapter.paragraphs.where(
      "position >= ?", start_position_target)
    if end_position_target
      res = res.where("position <= ?", end_position_target)
    end
    res.to_a
  end

  def build_paragraph_matches
    source_locs = get_locs(source_ps)
    target_locs = get_locs(target_ps)
    if source_locs.length > target_locs.length
      zm = get_zip_map(source_locs, target_locs)
      target_ps.each_with_index do |p, i|
        m = zm[i]
        self.paragraph_matches.build(
          position: i,
          source_start_position: source_ps[m[0]].position,
          source_end_position: source_ps[m[-1]].position,
          target_start_position: p.position,
          target_end_position: p.position,
          chapter_zip: self
        )
      end
    else
      zm = get_zip_map(target_locs, source_locs)
      source_ps.each_with_index do |p, i|
        m = zm[i]
        self.paragraph_matches.build(
          position: i,
          source_start_position: p.position,
          source_end_position: p.position,
          target_start_position: target_ps[m[0]].position,
          target_end_position: target_ps[m[-1]].position,
          chapter_zip: self
        )
      end
    end
  end
end
