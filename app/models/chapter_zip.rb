class ChapterZip < ApplicationRecord
  belongs_to :book_zip
  belongs_to :source_chapter, class_name: "Chapter"
  belongs_to :target_chapter, class_name: "Chapter"
  before_save :set_end_positions
  before_save :build_default_zip_info, if: :zip_info_generation_required?
  serialize :zip_info, JSON
  validates :start_position_source, :start_position_target, :position,
    presence: true


  def id_pos_mapping
    @id_pos_mapping ||= {
      source: source_ps.map.with_index{|p,i| [p.id, i]}.to_h,
      target: target_ps.map.with_index{|p,i| [p.id, i]}.to_h
    }
  end

  def matching_data=(m_data)
    matching = JSON.parse(m_data)
    vcsp = source_ps[matching['verifiedPMCursorSourceId']]
    self.zip_info = {
      ignored_source_ids: matching['skippedSource'].map{|i| source_ps[i].id},
      ignored_target_ids: matching['skippedTarget'].map{|i| target_ps[i].id},
      matches: matching['connections'].map do |c|
        [source_ps[c[0]].id, target_ps[c[1]].id]
      end,
      verified_connection_source_id: vcsp && vcsp.id,
      unverified_connection_source_ids: matching[
        'unverifiedConnectionSourceIds'].map{|i| source_ps[i].id}
    }
  end

  def matching_editor_data
    rel_matches = zip_info['matches'].map do |m|
      [id_pos_mapping[:source][m[0]], id_pos_mapping[:target][m[1]]]
    end
    unverified_connections =
      (zip_info['unverified_connection_source_ids'] || []).map{ |ucsid|
        id_pos_mapping[:source][ucsid]
    }
    s_ids = source_ps.map(&:id)
    t_ids = target_ps.map(&:id)
    vcsi = if zip_info["verified_connection_source_id"]
             s_ids.index( zip_info["verified_connection_source_id"])
           else
             s_ids.length
           end
    {
      'paragraphsSource' => source_ps.map{|p| {id: p.id, content: p.content}},
      'paragraphsTarget' => target_ps.map{|p| {id: p.id, content: p.content}},
      'skippedSource' =>  zip_info['ignored_source_ids'].map{
        |iid| s_ids.index(iid)},
      'skippedTarget' => zip_info['ignored_target_ids'].map{
        |iid| t_ids.index(iid)},
      'connections' => rel_matches,
      "verifiedPMCursorSourceId" => vcsi,
      "unverifiedConnectionSourceIds" => unverified_connections

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

  def rebuild_zip_info_external(source_ps_unmatched, target_ps_unmatched)
    body = {
      source_ps: source_ps_unmatched.map(&:content),
      target_ps: target_ps_unmatched.map(&:content)
    }
    headers = {'Content-Type': 'application/json'}
    uri = URI(Rails.configuration.chapter_matcher_ms[:url])
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.read_timeout = 240
    http.use_ssl = false
    begin
      response = JSON.parse(
        http.request_post(uri.path, body.to_json, headers).read_body
      )
    rescue Net::ReadTimeout
      s_len = (source_ps_unmatched.size/2).to_i
      t_len = (target_ps_unmatched.size/2).to_i
      body = {
        source_ps: source_ps_unmatched[..s_len].map(&:content),
        target_ps: target_ps_unmatched[..t_len].map(&:content)
      }
      response = JSON.parse(
        http.request_post(uri.path, body.to_json, headers).read_body
      )

    end
    new_matches = response["connections"].map do |c|
      [source_ps_unmatched[c[0]].id, target_ps_unmatched[c[1]].id]
    end
    unverified_connections = response['unverified_connections_source_id'].map do |si|
      source_ps_unmatched[si].id
    end
    return {
      new_matches: new_matches,
      unverified_connections: unverified_connections
    }
  end

  def rebuild_zip_info_fallback(source_ps_unmatched,
                                target_ps_unmatched)
    source_weights = get_weights(source_ps_unmatched)
    target_weights = get_weights(target_ps_unmatched)
    zipper = ChapterZipper.new(source_weights, target_weights)
    source_idx, target_idx = zipper.get_merge_idx
    source_starts = merge_points_to_pz_starts(source_ps_unmatched, source_idx)
    target_starts = merge_points_to_pz_starts(target_ps_unmatched, target_idx)
    return {
      new_matches: source_starts.zip(target_starts)[1..],
      unverified_connections: source_starts[1..]
    }

  end

  def rebuild_zip_info
    verified_match_idx = zip_info["matches"].find_index do |m|
      m[0] == zip_info["verified_connection_source_id"]
    end
    new_matches = zip_info["matches"][..verified_match_idx]
    first_verified_match = new_matches[-1]
    unverified_c_s_i = []
    verified_matches = [first_verified_match]
    verified_matches += zip_info["matches"][verified_match_idx+1..].filter do |m|
      zip_info["unverified_connection_source_ids"].exclude?(m[0])
    end

    verified_matches.zip(verified_matches[1..]).each do |vm, vm_next|
      source_idx_start = source_ps.find_index{|p| p.id == vm[0]}
      target_idx_start = target_ps.find_index{|p| p.id == vm[1]}
      if vm_next
        source_idx_end = source_ps.find_index{|p| p.id == vm_next[0]}
        target_idx_end = target_ps.find_index{|p| p.id == vm_next[1]}
      else
        source_idx_end = source_ps.length
        target_idx_end = target_ps.length
      end
      source_ps_unmatched = source_ps[source_idx_start...source_idx_end].filter do |p|
        zip_info["ignored_source_ids"].exclude? p.id
      end
      target_ps_unmatched = target_ps[target_idx_start...target_idx_end].filter do |p|
        zip_info["ignored_target_ids"].exclude? p.id
      end
      if Rails.configuration.chapter_matcher_ms[:enabled]
        res = rebuild_zip_info_external(source_ps_unmatched, target_ps_unmatched)
      else
        res = rebuild_zip_info_fallback(source_ps_unmatched, target_ps_unmatched)
      end
      new_matches += res[:new_matches]
      new_matches.append(vm_next) if vm_next
      unverified_c_s_i += res[:unverified_connections]
    end
    zip_info['matches'] = new_matches
    zip_info['unverified_connection_source_ids'] = unverified_c_s_i
  end

  def build_default_zip_info
    self.zip_info = {
      "matches" => [[source_ps[0].id, target_ps[0].id]],
      "ignored_source_ids" => [],
      "ignored_target_ids" => [],
      "verified_connection_source_id" => source_ps[0].id,
      "unverified_connection_source_ids" => []
    }
    rebuild_zip_info
  end

  def build_next_chapter_allowed?
    (book_zip.chapter_zips.last.id == self.id) &&
      zip_info['verified_connection_source_id'].nil? &&
      !final_chapter?
  end

  def next_chapter_message
    @next_chapter_message ||=
      if zip_info['verified_connection_source_id'].present?
        "Current chapter is not verified."
      elsif final_chapter?
        "This is the final chapter zip!"
      end
  end

  def final_chapter?
    build_next_chapter_zip.nil?
  end

  def next_chapter_zip
    @next_chapter_zip ||=
      book_zip.chapter_zips.where("position > ?", position).first
  end

  def prev_chapter_zip
    @prev_chapter_zip ||=
      book_zip.chapter_zips.where("position < ?", position).last
  end

  def build_next_chapter_zip
    @build_next_chapter_zip ||= begin
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
        pos = book_zip.chapter_zips.maximum(:position) + 1
        ChapterZip.new(
          position: pos,
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
