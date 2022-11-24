class CreateChapters < ActiveRecord::Migration[6.1]
  def change
    create_table :chapters do |t|
      t.string :title
      t.integer :position
      t.references :epub_book

      t.timestamps
    end
  end
end
