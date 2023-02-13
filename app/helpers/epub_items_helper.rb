module EpubItemsHelper
  def prev_next_epub_items(epub_item)
    epub_book = epub_item.epub_book
    next_epub_item = epub_book.epub_items.where(
      "position > (?)", epub_item.position
    ).first
    prev_epub_item = epub_book.epub_items.where(
      "position < (?)", epub_item.position).last
    res = ""
    if prev_epub_item
      res += link_to "Prev", epub_book_epub_item_path(epub_book, prev_epub_item)
    end
      res += ' '
    if next_epub_item
      res += link_to "Next", epub_book_epub_item_path(epub_book, next_epub_item)
    end
    res.html_safe
  end
end
