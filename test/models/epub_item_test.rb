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

  test "#update_title" do
    current_title = {"h1" => 'Book 1', "h2" => "Part 1", 'h3' => "Chapter 1"}
    item = epub_items(:two)
    doc = Nokogiri::HTML(item.content)
    assert item.update_title(current_title, doc.xpath('/html/body/div/h2')[0], false)
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
