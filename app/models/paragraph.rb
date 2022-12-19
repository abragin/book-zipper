class Paragraph < ApplicationRecord
  belongs_to :chapter
  scope :active, -> { where(ignore: false) }
end
