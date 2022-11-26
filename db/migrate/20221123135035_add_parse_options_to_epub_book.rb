class AddParseOptionsToEpubBook < ActiveRecord::Migration[6.1]
  def change
    change_table :epub_books do |t|
      t.string :content_location
      t.string :title_tags
      t.string :content_tag
      t.string :excluded_content_tag
      t.integer :start_position
      t.integer :end_position
    end
  end
end
