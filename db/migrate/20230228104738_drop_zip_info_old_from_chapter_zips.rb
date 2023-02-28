class DropZipInfoOldFromChapterZips < ActiveRecord::Migration[7.0]
  def change
    remove_column :chapter_zips, :zip_info_old, :text
  end
end
