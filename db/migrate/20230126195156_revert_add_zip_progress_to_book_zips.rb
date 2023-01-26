class RevertAddZipProgressToBookZips < ActiveRecord::Migration[6.1]
  def change
    remove_reference :book_zips, :current_source_paragraph
    remove_reference :book_zips, :current_target_paragraph
    remove_column :book_zips, :in_progress, :boolean, default: true
  end
end
