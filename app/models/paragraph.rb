class Paragraph < ApplicationRecord
  belongs_to :chapter
  before_create :strip_content
  scope :active, -> { where(ignore: false) }

  def strip_content
    content.strip!
  end
end
