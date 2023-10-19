class BookZip < ApplicationRecord
  belongs_to :ebook_source, class_name: "EpubBook"
  belongs_to :ebook_target, class_name: "EpubBook"
  has_many :chapter_zips,
    -> { order('position') },
     dependent: :destroy

  def title
    "#{ebook_source.book.title} (#{ebook_source.language.name} - #{ebook_target.language.name})"
  end

  def title_with_author
    "#{ebook_source.book.author.name} - #{title}"
  end

  def chapter_zips_with_extra_includes
    chapter_zips.includes(
      source_chapter: :epub_book,
      target_chapter: :epub_book
    )
  end

  def export_hash
    chapters = chapter_zips.map do |cz|
      paragraphs = cz.paragraph_matches.map do |pm|
        {
          source_paragraphs: pm.source_paragraphs.map do |p|
            {
              content: p.content,
              ignored: cz.zip_info['ignored_source_ids'].include?(p.id)
            }
          end,
          target_paragraphs: pm.target_paragraphs.map do |p|
            {
              content: p.content,
              ignored: cz.zip_info['ignored_target_ids'].include?(p.id)
            }
          end
        }
      end
      {
        source_title: cz.source_chapter.title,
        target_title: cz.target_chapter.title,
        paragraphs: paragraphs
      }
    end
    {
      title: ebook_source.book.title,
      author: ebook_source.book.author.name,
      source_language: ebook_source.language.name,
      target_language: ebook_target.language.name,
      chapters: chapters
    }
  end
end
