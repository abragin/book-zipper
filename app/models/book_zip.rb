class BookZip < ApplicationRecord
  belongs_to :ebook_source, class_name: "EpubBook"
  belongs_to :ebook_target, class_name: "EpubBook"
  has_many :chapter_zips,
    -> { order('position') },
     dependent: :destroy

  def title
    "#{ebook_source.book.author.name} - #{ebook_source.book.title} (#{ebook_source.language.name} - #{ebook_target.language.name})"
  end

  def chapter_zips_with_extra_includes
    chapter_zips.includes(
      source_chapter: :epub_book,
      target_chapter: :epub_book
    )
  end
end
