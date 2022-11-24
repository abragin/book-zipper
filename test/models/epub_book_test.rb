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
end
