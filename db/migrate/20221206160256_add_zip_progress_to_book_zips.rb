class AddZipProgressToBookZips < ActiveRecord::Migration[6.1]
  def change
    change_table :book_zips do |t|
      t.references :current_source_paragraph
      t.references :current_target_paragraph
      t.boolean :in_progress, default: true
    end
  end
end
