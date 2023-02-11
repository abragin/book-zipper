require "test_helper"

class ChapterZipperTest < ActiveSupport::TestCase
  include CustomTitleProcessing

  test "#update_title_the_golden_calf_en" do
    f1 = file_fixture("custom_title_processing/golden_calf_en_t1.html")
    f2 = file_fixture("custom_title_processing/golden_calf_en_t2.html")
    doc1 = Nokogiri::HTML(f1.read).xpath("/html/body/div")
    doc2 = Nokogiri::HTML(f2.read).xpath("/html/body/div")
    current_title = {}
    assert_nil update_title_the_golden_calf_en(current_title, doc1.children[0])
    assert_equal({}, current_title)
    current_tag = doc1.children[1]
    assert update_title_the_golden_calf_en(current_title, current_tag)
    assert_equal({"p.calibre_16" => "PART 1"}, current_title)
    current_tag = doc1.children[3]
    assert update_title_the_golden_calf_en(current_title, current_tag)
    assert_equal({"p.calibre_16" => "PART 1 THE CREW OF"}, current_title)
    current_tag = doc1.children[5]
    assert update_title_the_golden_calf_en(current_title, current_tag)
    assert_equal({"p.calibre_16" => "PART 1 THE CREW OF THE ANTELOPE"}, current_title)
    current_tag = doc2.children[1]
    assert update_title_the_golden_calf_en(current_title, current_tag)
    assert_equal({
      "p.calibre_16" => "PART 1 THE CREW OF THE ANTELOPE",
      "p.calibre_" => "CHAPTER 1"
    }, current_title)
    current_tag = doc2.children[3]
    assert update_title_the_golden_calf_en(current_title, current_tag)
    assert_equal "CHAPTER 1 HOW PANIKOVSKY", current_title["p.calibre_" ]
    current_tag = doc2.children[5]
    assert update_title_the_golden_calf_en(current_title, current_tag)
    assert_equal "CHAPTER 1 HOW PANIKOVSKY BROKE THE PACT", current_title["p.calibre_" ]
    current_tag = doc2.children[7]
    assert_equal 'p', current_tag.name
    assert_nil update_title_the_golden_calf_en(current_title, current_tag)
    assert_equal({
      "p.calibre_16" => "PART 1 THE CREW OF THE ANTELOPE",
      "p.calibre_" => "CHAPTER 1 HOW PANIKOVSKY BROKE THE PACT"
    }, current_title)
    current_tag = doc1.children[1]
    assert update_title_the_golden_calf_en(current_title, current_tag)
    assert_equal({"p.calibre_16" => "PART 1"}, current_title)
  end
end
