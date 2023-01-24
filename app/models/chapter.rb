class Chapter < ApplicationRecord
  has_many :paragraphs,
    -> { order('position') },
     dependent: :destroy
  belongs_to :epub_book

  def max_p_position
    paragraphs.maximum(:position)
  end

  def title_with_len
    "#{title} (#{max_p_position})"
  end
end
