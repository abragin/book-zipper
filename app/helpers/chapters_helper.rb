module ChaptersHelper
  def prev_next_chapters(chapter)
    epub_book = chapter.epub_book
    next_chapter = epub_book.chapters.where(
      "position > (?)", chapter.position
    ).first
    prev_chapter = epub_book.chapters.where(
      "position < (?)", chapter.position).last
    res = ""
    if prev_chapter
      res += link_to "Prev", epub_book_chapter_path(epub_book, prev_chapter)
    end
      res += ' '
    if next_chapter
      res += link_to "Next", epub_book_chapter_path(epub_book, next_chapter)
    end
    res.html_safe
  end
end
