class CreateEpubItems < ActiveRecord::Migration[6.1]
  def change
    create_table :epub_items do |t|
      t.integer :position
      t.string :name
      t.text :content
      t.references :epub_book, null: false, foreign_key: true

      t.timestamps
    end
  end
end
