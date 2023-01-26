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

end
