class RemoveTitleTags < ActiveRecord::Migration[7.0]
  def change
    remove_column :epub_books, :title_tags, :string
  end
end
