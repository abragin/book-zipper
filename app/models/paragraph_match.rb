class ParagraphMatch < ApplicationRecord
  belongs_to :chapter_zip
  delegate :source_chapter, :to => :chapter_zip, :allow_nil => false
  delegate :target_chapter, :to => :chapter_zip, :allow_nil => false

  def paragraphs_source
    source_chapter.paragraphs.where(
      position: (source_start_position..source_end_position))
  end

  def paragraphs_target
    target_chapter.paragraphs.where(
      position: (target_start_position..target_end_position))
  end
end
