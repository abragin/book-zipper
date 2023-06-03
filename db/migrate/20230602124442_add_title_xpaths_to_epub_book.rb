class AddTitleXpathsToEpubBook < ActiveRecord::Migration[7.0]
  def change
    change_table :epub_books do |t|
      t.string :title_xpaths
    end
  end
end
