class AddParseOptionsToEpubBook < ActiveRecord::Migration[6.1]
  def change
    change_table :epub_books do |t|
      t.string :title_parsing
      t.string :content_parsing
      t.string :excluded_content
      t.integer :start_position
      t.integer :end_position
    end
  end
end
