require "test_helper"

class ChepterZipTest < ActiveSupport::TestCase
  test '#build_paragraph_matches' do
    new_cz = ChapterZip.create(
      book_zip: book_zips(:bookzipone),
      source_chapter: chapters(:one),
      target_chapter: chapters(:two)
    )
    #new_ch = ChapterZip.new()
    #assert new_cz
    assert_equal "chapter_one - chapter_two", new_cz.title
    new_cz.build_paragraph_matches
    assert_equal 2, new_cz.paragraph_matches.length
  end

  test "#get_zip_map" do
    loc_target = [0.33, 0.66]
    loc_source = [0.1, 0.4, 0.8]
    cz = ChapterZip.new
    assert_equal [[0,1],[2]],
      cz.get_zip_map(loc_source, loc_target)
    loc_source = [0.1, 0.2, 0.3]
    assert_equal [[0,1],[2]],
      cz.get_zip_map(loc_source, loc_target)
    loc_source = [0.1, 0.7, 0.8]
    assert_equal [[0],[1,2]],
      cz.get_zip_map(loc_source, loc_target)
  end
end
