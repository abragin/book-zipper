class RemoveTitleFromChapterZip < ActiveRecord::Migration[6.1]
  def change
    remove_column :chapter_zips, :title, :string
  end
end
