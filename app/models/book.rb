class Book < ApplicationRecord
  belongs_to :author
  has_many :epub_books
end
