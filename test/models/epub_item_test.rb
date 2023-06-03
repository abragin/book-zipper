require "test_helper"

class EpubItemTest < ActiveSupport::TestCase
  test "#parse_content" do
    item = epub_items(:one)
    current_title = Hash.new('')
    content = [['', []]]
    item.parse_content(current_title, content)
    t1_exp = {"h1" => 'Book 1', "h2" => "Part 1", 'h3' => "Chapter 1"}
    assert_equal t1_exp, current_title
    assert_equal [["Book 1/Part 1/Chapter 1", ["First paragraph", "Second Paragraph"]]], content

    item = epub_items(:two)
    content = [['', []]]
    item.parse_content(current_title, content)
    t2_exp = {"h1" => 'Book 1', "h2" => "Part 2", 'h3' => ""}
    assert_equal t2_exp, current_title
    assert_equal [["Book 1/Part 2", ["Third  paragraph"]]], content

    item = epub_items(:three)
    content = [['', []]]
    item.parse_content(current_title, content)
    t3_exp = {"h1" => 'Book 1', "h2" => "Part 2", 'h3' => "Chapter 1"}
    assert_equal t3_exp, current_title
    assert_equal [["Book 1/Part 2/Chapter 1", ["Forth paragraph", "Fifth paragraph"]]], content

    item = epub_items(:four)
    content = [[item.title_to_text(current_title), []]]
    item.parse_content(current_title, content)
    t4_exp = {"h1" => 'Book 1', "h2" => "Part 2", 'h3' => "Chapter 2"}
    assert_equal t4_exp, current_title
    p_res_exp = [["Book 1/Part 2/Chapter 1", ["Sixth paragraph"]],
                 ["Book 1/Part 2/Chapter 2", ["Seventh paragraph"]]]
    assert_equal p_res_exp, content
  end

  test "#parse_content with complex title" do
    book = EpubBook.new({
      content_tag: "p",
      title_xpaths: [
        "h1", "p[@class='header']",
        "p[descendant-or-self::*/text()[starts-with(normalize-space(), 'PART')]]",
        "p[@class='title' and descendant-or-self::*/text()[starts-with(normalize-space(), 'Chapter')]]"
      ]
    })
    item = EpubItem.new({
      epub_book: book,
      content: <<-EOF
      <html><body>
        <h1 class=\"header\">BOOK 1 title</h1>
        <p> some text 1 </p>
        <h2 class=\"header\">PART 1 title should be removed</h2>
        <p>CHAPTER 1 it is an ordinary paragraph</p>
        <p class=\"header\">VOLUME 1 title</p>
        <p> some text 2</p>
        <p class=\"header_1\">PART 1 title</p>
        <p> some text 3</p>
        <p class=\"title\"> <span> Chapter 1 title </span></p>
        <p> some text 4</p>
      </body></html>
EOF
    })
    current_title = Hash.new('')
    current_content = [['', []]]
    item.parse_content(current_title, current_content)
    assert_equal [
      "BOOK 1 title", [
        " some text 1 ",
        "CHAPTER 1 it is an ordinary paragraph"
      ]
    ], current_content[0]
    assert_equal [
      "BOOK 1 title/VOLUME 1 title", [
        " some text 2",
      ]
    ], current_content[1]
    assert_equal [
      "BOOK 1 title/VOLUME 1 title/PART 1 title", [
        " some text 3",
      ]
    ], current_content[2]
    assert_equal [
      "BOOK 1 title/VOLUME 1 title/PART 1 title/Chapter 1 title", [
        " some text 4",
      ]
    ], current_content[3]
  end

  test "#update_title" do
    current_title = {"h1" => 'Book 1', "h2" => "Part 1", 'h3' => "Chapter 1"}
    item = epub_items(:two)
    doc = Nokogiri::HTML(item.content)
    title_items = item.epub_book.title_xpaths.map do |txp|
      doc.xpath("/html/body/div/" + txp)
    end
    assert item.update_title(
      current_title, doc.xpath('/html/body/div/h2')[0], false, title_items)
    exp = {"h1" => 'Book 1', "h2" => "Part 2", 'h3' => ""}
    assert_equal exp, current_title
  end

  test "#title_to_text" do
    current_title = {"h1" => 'Book 1', "h2" => "", 'h3' => "Chapter 1"}
    item = epub_items(:two)
    res = item.title_to_text(current_title)
    assert_equal "Book 1/Chapter 1",res
  end
end
