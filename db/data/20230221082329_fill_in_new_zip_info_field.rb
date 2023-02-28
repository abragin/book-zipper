# frozen_string_literal: true

class FillInNewZipInfoField < ActiveRecord::Migration[7.0]
  def up
    ChapterZip.all.each do |cz|
      matches = cz.paragraph_matches.map do |pm|
        [pm.source_paragraphs.first.id, pm.target_paragraphs.first.id]
      end
      cz.update(
        zip_info_new:
        {matches: matches, ignored_source_ids: [], ignored_target_ids: []}
      )
    end
  end

  def down
  end
end
