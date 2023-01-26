class ParagraphMatch < ApplicationRecord
  belongs_to :chapter_zip
  has_and_belongs_to_many :source_paragraphs, -> { order(:position) },
    class_name: "Paragraph",
    join_table: "paragraph_matches_source_paragraphs"
  has_and_belongs_to_many :target_paragraphs, -> { order(:position) },
    class_name: "Paragraph",
    join_table: "paragraph_matches_target_paragraphs"
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
