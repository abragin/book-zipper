class MakeLangAndBookNotNullableInEpubBook < ActiveRecord::Migration[6.1]
  def change
    change_column_null :epub_books, :language_id, false
    change_column_null :epub_books, :book_id, false
  end
end
