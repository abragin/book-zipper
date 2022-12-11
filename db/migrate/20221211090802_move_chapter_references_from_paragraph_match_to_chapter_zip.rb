class MoveChapterReferencesFromParagraphMatchToChapterZip < ActiveRecord::Migration[6.1]
  def change
    change_table :chapter_zips do |t|
      t.references :source_chapter
      t.references :target_chapter
    end

    change_table :paragraph_matches do |t|
      t.remove_references :source_chapter
      t.remove_references :target_chapter
    end
  end
end
