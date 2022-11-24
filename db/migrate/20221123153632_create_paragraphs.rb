class CreateParagraphs < ActiveRecord::Migration[6.1]
  def change
    create_table :paragraphs do |t|
      t.integer :position
      t.text :content
      t.references :chapter

      t.timestamps
    end
  end
end
