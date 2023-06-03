class RenameContentTagToContentXpath < ActiveRecord::Migration[7.0]
  def change
    rename_column :epub_books, :content_tag, :content_xpath
  end
end
