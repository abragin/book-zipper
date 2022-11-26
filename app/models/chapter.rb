class Chapter < ApplicationRecord
  has_many :paragraphs, dependent: :destroy
  belongs_to :epub_book
end
