class AddBookAndLanguageReferenceToEpubBook < ActiveRecord::Migration[6.1]
  def change
    add_reference :epub_books, :book
    add_reference :epub_books, :language
  end
end
