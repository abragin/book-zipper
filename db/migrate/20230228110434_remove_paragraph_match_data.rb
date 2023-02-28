class RemoveParagraphMatchData < ActiveRecord::Migration[7.0]
  def change
    drop_table :paragraph_matches_source_paragraphs
    drop_table :paragraph_matches_target_paragraphs
    drop_table :paragraph_matches
  end
end
