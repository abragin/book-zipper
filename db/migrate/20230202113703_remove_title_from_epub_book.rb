class RemoveTitleFromEpubBook < ActiveRecord::Migration[6.1]
  def change
    remove_column :epub_books, :title, :string
  end
end
