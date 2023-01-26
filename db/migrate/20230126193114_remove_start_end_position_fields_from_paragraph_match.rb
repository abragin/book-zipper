class RemoveStartEndPositionFieldsFromParagraphMatch < ActiveRecord::Migration[6.1]
  def change
    remove_column :paragraph_matches, :source_start_position, :integer
    remove_column :paragraph_matches, :source_end_position, :integer
    remove_column :paragraph_matches, :target_start_position, :integer
    remove_column :paragraph_matches, :target_end_position, :integer
  end
end
