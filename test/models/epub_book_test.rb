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
    assert_equal 1, epub_book.epub_items.length
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

  test "#title_conditions" do
    book = EpubBook.new({
      title_tags: ["h1", "p.header", "p>PART ", "p.title>Chapter "]
    })
    t_cond = book.title_conditions
    assert_equal({tag: "h1"}, t_cond[0])
    assert_equal({tag: "p", class: "header"}, t_cond[1])
    assert_equal({tag: "p", start: "PART "}, t_cond[2])
    assert_equal({tag: "p", class: "title", start: "Chapter "}, t_cond[3])
  end

  def build_node(xml_text)
    Nokogiri::XML(xml_text).children[0]
  end

  test "#matching_tag_position" do
    book = EpubBook.new({
      title_tags: ["h1", "p.header", "p>PART ", "p.title>Chapter "]
    })
    current_node = build_node("<h1 class=\"header\">PART 1 title</h1>")
    assert_equal 0, book.matching_tag_position(current_node)

    current_node = build_node("<h2 class=\"header\">PART 1 title</h2>")
    assert_nil book.matching_tag_position(current_node)

    current_node = build_node("<p>CHAPTER 1 </p>")
    assert_nil book.matching_tag_position(current_node)

    current_node = build_node("<p class=\"header\">PART 1 title</p>")
    assert_equal 1, book.matching_tag_position(current_node)

    current_node = build_node("<p class=\"header_1\">PART 1 title</p>")
    assert_equal 2, book.matching_tag_position(current_node)

    current_node = build_node(
      "<p class=\"title\"> <span> Chapter 1 title </span></p>")
    assert_equal 3, book.matching_tag_position(current_node)

  end
end
