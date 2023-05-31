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
      ],
      [
        paragraphs(:five_sentence_paragraph_c1).id,
        paragraphs(:five_sentence_paragraph_c2).id,
      ],[
        paragraphs(:one_sentence_paragraph_c1).id,
        paragraphs(:one_sentence_paragraph_c2).id,
      ]
      ],
      "ignored_source_ids" => [], "ignored_target_ids" => [],
      "verified_connection_source_id" => paragraphs(:nine_sentence_paragraph).id,
      "unverified_connection_source_ids" => [
        paragraphs(:one_sentence_paragraph_again).id,
        paragraphs(:five_sentence_paragraph_c1).id,
        paragraphs(:one_sentence_paragraph_c1).id
      ]
    }
    cz.build_default_zip_info
    assert_equal expected_zi, cz.zip_info
  end

  test "#matching_editor_data" do
    cz = chapter_zips(:one)
    cz.zip_info = {
      "matches" => [[
        paragraphs(:nine_sentence_paragraph).id,
        paragraphs(:ten_sentence_paragraph).id,
      ],[
        paragraphs(:one_sentence_paragraph_again).id,
        paragraphs(:another_one_sentence_paragraph).id,
      ]],
      "ignored_source_ids" => [paragraphs(:one_sentence_paragraph).id],
      "ignored_target_ids" => [paragraphs(:another_one_sentence_paragraph).id]
    }
    med = cz.matching_editor_data
    assert_equal [[0,0], [2,1]], med['connections']
    assert_equal [1], med['skippedSource']
    assert_equal [1], med['skippedTarget']
  end

  test "#rebuild_zip_info" do
    cz = chapter_zips(:one)
    matches = [[
        paragraphs(:nine_sentence_paragraph).id,
        paragraphs(:ten_sentence_paragraph).id,
      ],[
        paragraphs(:one_sentence_paragraph).id,
        paragraphs(:another_one_sentence_paragraph).id,
      ]]
    cz.zip_info = {
      "matches" => [matches[0]],
      "ignored_source_ids" => [
        paragraphs(:one_sentence_paragraph_again).id,
        paragraphs(:five_sentence_paragraph_c1).id,
        paragraphs(:one_sentence_paragraph_c1).id,
      ],
      "ignored_target_ids" => [
        paragraphs(:five_sentence_paragraph_c2).id,
        paragraphs(:one_sentence_paragraph_c2).id,
      ],
      "verified_connection_source_id" => paragraphs(
        :nine_sentence_paragraph).id,
      "unverified_connection_source_ids" => []
    }
    cz.rebuild_zip_info
    assert_equal matches, cz.zip_info['matches']
  end

  test "#rebuild_zip_info with verified connection in the middle" do
    cz = chapter_zips(:one)
    matches = [[
        paragraphs(:nine_sentence_paragraph).id,
        paragraphs(:ten_sentence_paragraph).id,
      ],[
        paragraphs(:one_sentence_paragraph_again).id,
        paragraphs(:another_one_sentence_paragraph).id,
      ],[
        paragraphs(:five_sentence_paragraph_c1).id,
        paragraphs(:five_sentence_paragraph_c2).id,
      ],[
        paragraphs(:one_sentence_paragraph_c1).id,
        paragraphs(:one_sentence_paragraph_c2).id,
      ]]
    cz.zip_info = {
      "matches" => [
        matches[0],
        [
          paragraphs(:one_sentence_paragraph).id,
          paragraphs(:another_one_sentence_paragraph).id,
        ], #wrong one
        matches[2]
        # last one is missing
      ],
      "ignored_source_ids" => [],
      "ignored_target_ids" => [],
      "verified_connection_source_id" => paragraphs(
        :nine_sentence_paragraph).id,
      "unverified_connection_source_ids" => [paragraphs(:one_sentence_paragraph_again).id]
    }
    cz.rebuild_zip_info
    assert_equal matches, cz.zip_info['matches']
    assert_equal [matches[1][0], matches[3][0]],
      cz.zip_info['unverified_connection_source_ids']
  end


end
