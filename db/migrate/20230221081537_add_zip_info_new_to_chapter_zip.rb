class AddZipInfoNewToChapterZip < ActiveRecord::Migration[7.0]
  def change
    change_table :chapter_zips do |t|
      t.text :zip_info_new
    end
  end
end
