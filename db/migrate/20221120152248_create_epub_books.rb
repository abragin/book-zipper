class CreateEpubBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :epub_books do |t|
      t.string :title
      t.string :filename

      t.timestamps
    end
  end
end
