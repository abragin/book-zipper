class CreateChapterZips < ActiveRecord::Migration[6.1]
  def change
    create_table :chapter_zips do |t|
      t.string :title
      t.references :book_zip
      t.integer :position

      t.timestamps
    end
  end
end
