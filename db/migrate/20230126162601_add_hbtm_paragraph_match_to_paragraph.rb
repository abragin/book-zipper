class AddHbtmParagraphMatchToParagraph < ActiveRecord::Migration[6.1]
  def change
    create_table :paragraph_matches_source_paragraphs, id: false do |t|
      t.belongs_to :paragraph_match
      t.belongs_to :paragraph
    end

    create_table :paragraph_matches_target_paragraphs, id: false do |t|
      t.belongs_to :paragraph_match
      t.belongs_to :paragraph
    end
  end
end
