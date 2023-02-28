require "test_helper"

class ChapterZipTest < ActiveSupport::TestCase

  test '#build_default_zip_info' do
    cz = ChapterZip.new(
      book_zip: book_zips(:bookzipone),
      source_chapter: chapters(:one),
      target_chapter: chapters(:two)
    )
    expected_zi = {
      "matches" => [[
        paragraphs(:nine_sentence_paragraph).id,
        paragraphs(:ten_sentence_paragraph).id,
      ],[
        paragraphs(:one_sentence_paragraph_again).id,
        paragraphs(:another_one_sentence_paragraph).id,
      ]],
      "ignored_source_ids" => [], "ignored_target_ids" => []
    }
    cz.build_default_zip_info
    assert_equal expected_zi, cz.zip_info
  end
end
