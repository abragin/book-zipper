class AddCustomUpdateTitleToEpubBook < ActiveRecord::Migration[6.1]
  def change
    change_table :epub_books do |t|
      t.string :custom_update_title, default: "", nil: false
    end
  end
end
