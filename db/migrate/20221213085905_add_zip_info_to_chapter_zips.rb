class AddZipInfoToChapterZips < ActiveRecord::Migration[6.1]
  def change
    change_table :chapter_zips do |t|
      t.text :zip_info, nil: false
    end
  end
end
