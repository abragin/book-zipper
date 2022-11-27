class Chapter < ApplicationRecord
  has_many :paragraphs,
    -> { order('position') },
     dependent: :destroy
  belongs_to :epub_book
end
