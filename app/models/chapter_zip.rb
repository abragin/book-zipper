class ChapterZip < ApplicationRecord
  belongs_to :book_zip
  belongs_to :source_chapter, class_name: "Chapter"
  belongs_to :target_chapter, class_name: "Chapter"
  before_create :set_end_positions
  before_save :build_default_zip_info, if: :zip_info_generation_required?
  serialize :zip_info, JSON
  #serialize :zip_info_new, JSON

  def id_pos_mapping
    @id_pos_mapping ||= {
      source: source_ps.map.with_index{|p,i| [p.id, i]}.to_h,
      target: target_ps.map.with_index{|p,i| [p.id, i]}.to_h
    }
  end

  def matching_data=(m_data)
    matching = JSON.parse(m_data)
    self.zip_info = {
      ignored_source_ids: matching['skippedSource'].map{|i| source_ps[i].id},
      ignored_target_ids: matching['skippedTarget'].map{|i| target_ps[i].id},
      matches: matching['connections'].map do |c|
        [source_ps[c[0]].id, target_ps[c[1]].id]
      end
    }
  end

  def matching_editor_data
    rel_matches = zip_info['matches'].map do |m|
      [id_pos_mapping[:source][m[0]], id_pos_mapping[:target][m[1]]]
    end
    s_ids = source_ps.map(&:id)
    t_ids = target_ps.map(&:id)
    {
      'paragraphsSource' => source_ps.map{|p| {id: p.id, content: p.content}},
      'paragraphsTarget' => target_ps.map{|p| {id: p.id, content: p.content}},
      'skippedSource' =>  zip_info['ignored_source_ids'].map{
        |iid| s_ids.index(iid)},
      'skippedTarget' => zip_info['ignored_target_ids'].map{
        |iid| t_ids.index(iid)},
      'connections' => rel_matches
    }
  end

  def merge_points_to_pz_starts(ps, merge_idx)
    (0...ps.size).reduce([]) do |acc, ind|
      if merge_idx.include?(ind)
        acc
      else
        acc + [ps[ind].id]
      end
    end
  end

  def build_default_zip_info
    source_weights = get_weights(source_ps)
    target_weights = get_weights(target_ps)
    zipper = ChapterZipper.new(source_weights, target_weights)
    source_idx, target_idx = zipper.get_merge_idx
    source_starts = merge_points_to_pz_starts(source_ps, source_idx)
    target_starts = merge_points_to_pz_starts(target_ps, target_idx)
    self.zip_info = {
      "matches" => source_starts.zip(target_starts),
      "ignored_source_ids" => [],
      "ignored_target_ids" => []
    }
  end

  def next_chapter_zip
    if source_chapter.max_p_position == end_position_source
      next_s_chapter = book_zip.ebook_source.chapters.where(
        "position > ?", source_chapter.position).order(:position).first
      next_s_position = 0
    else
      next_s_chapter = source_chapter
      next_s_position = end_position_source + 1
    end
    if target_chapter.max_p_position == end_position_target
      next_t_chapter = book_zip.ebook_target.chapters.where(
        "position > ?", target_chapter.position).order(:position).first
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

  def get_weights(ps)
    ps_ls = ps.map do |p|
      p.content.split().length
    end
    len_total = ps_ls.sum.to_f
    ps_ls.map{|l| l/len_total}
  end

  def title
    "#{source_chapter.title} - #{target_chapter.title}"
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

  def paragraph_matches
    @paragraph_matches ||=
      begin
        source_id_map = source_ps.map.with_index{|p,i| [p.id, i]}.to_h
        target_id_map = target_ps.map.with_index{|p,i| [p.id, i]}.to_h
        matches_idx = zip_info["matches"].map do |m|
          [source_id_map[m[0]], target_id_map[m[1]]]
        end
        matches_idx.append([source_ps.size, target_ps.size])
        matches_idx.each_cons(2).map do |m1, m2|
          ParagraphMatch.new(
            source_paragraphs: source_ps[m1[0]...m2[0]],
            target_paragraphs: target_ps[m1[1]...m2[1]]
          )
        end
    end
  end

  protected

  def zip_info_generation_required?
    new_record? || (
      source_chapter_changed? || target_chapter_changed? ||
      start_position_source_changed? || end_position_source_changed? ||
      start_position_target_changed? || end_position_target_changed?
    )
  end
end
