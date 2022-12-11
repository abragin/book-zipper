class CreateParagraphMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :paragraph_matches do |t|
      t.references :chapter_zip
      t.integer :position
      t.references :source_chapter
      t.integer :source_start_position
      t.integer :source_end_position
      t.references :target_chapter
      t.integer :target_start_position
      t.integer :target_end_position

      t.timestamps
    end
  end
end
