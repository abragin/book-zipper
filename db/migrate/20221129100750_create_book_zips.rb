class CreateBookZips < ActiveRecord::Migration[6.1]
  def change
    create_table :book_zips do |t|
      t.references :ebook_source
      t.references :ebook_target

      t.timestamps
    end
  end
end
