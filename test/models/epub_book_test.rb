require "test_helper"

class DummyEpubFile
  attr_accessor :tempfile, :original_filename
end

class EpubBookTest < ActiveSupport::TestCase
  test "file param is turned into correct EpubItem" do
    df = DummyEpubFile.new
    df.original_filename = "simple_book.epub"
    df.tempfile = file_fixture("simple_book.epub")
    epub_book = EpubBook.new
    epub_book.file = df
    assert_equal 2, epub_book.epub_items.length
    epub_item = epub_book.epub_items[0]
    assert_equal 'item_name', epub_item.name
    assert_match /the first page/, epub_item.content
  end

  test "#store_structured" do
    book = epub_books(:testepubbook)
    book.store_structured
    assert_equal 4, book.chapters.length
    chs = ["Book 1/Part 1/Chapter 1", "Book 1/Part 2",
           "Book 1/Part 2/Chapter 1", "Book 1/Part 2/Chapter 2"]
    assert_equal chs, book.chapters.map{|c| c.title}
    assert_equal ["First paragraph", "Second Paragraph"],
      book.chapters[0].paragraphs.map{|p| p.content}
    assert_equal ["Forth paragraph", "Fifth paragraph", "Sixth paragraph"],
      book.chapters[2].paragraphs.map{|p| p.content}
    assert_equal ["Seventh paragraph"],
      book.chapters[3].paragraphs.map{|p| p.content}
  end

  test "#store_structured with do content_tag and excluded_content_tag" do
    book = epub_books(:nodivandabook)
    book.store_structured
    assert_equal 1, book.chapters.length
    assert_equal 'Chapter 1', book.chapters[0].title
    assert_equal 'First paragraph', book.chapters[0].paragraphs[0].content
  end
end
