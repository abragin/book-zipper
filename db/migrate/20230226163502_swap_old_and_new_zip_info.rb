class SwapOldAndNewZipInfo < ActiveRecord::Migration[7.0]
  def change
    rename_column :chapter_zips, :zip_info, :zip_info_old
    rename_column :chapter_zips, :zip_info_new, :zip_info
  end
end
