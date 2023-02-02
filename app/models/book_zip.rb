class BookZip < ApplicationRecord
  belongs_to :ebook_source, class_name: "EpubBook"
  belongs_to :ebook_target, class_name: "EpubBook"
  has_one :current_source_paragraph, class_name: "Paragraph"
  has_one :current_target_paragraph, class_name: "Paragraph"
  has_many :chapter_zips,
    -> { order('position') },
     dependent: :destroy

  def title
    "#{ebook_source.book.title} (#{ebook_source.language.name} - #{ebook_target.language.name})"
  end
end
