require "test_helper"

class ChepterZipTest < ActiveSupport::TestCase
  test '#build_paragraph_matches' do
    new_cz = ChapterZip.create(
      book_zip: book_zips(:bookzipone),
      source_chapter: chapters(:one),
      target_chapter: chapters(:two)
    )
    assert_equal "chapter_one - chapter_two", new_cz.title
    assert_equal 2, new_cz.paragraph_matches.length
  end

  test '#build_groupped_ps' do
    z_inf = {'attach_ids' => [chapters(:one).paragraphs[1].id], 'ignore_ids' => []}
    bgp_res = ChapterZip.new.build_groupped_ps(chapters(:one).paragraphs, z_inf)
    assert_equal 2, bgp_res.length
    assert_equal 2, bgp_res[0].length
    assert_equal 1, bgp_res[1].length
  end

  test "#get_attach_idxs" do
    loc_target = [0.33, 0.66]
    loc_source = [0.1, 0.4, 0.8]
    cz = ChapterZip.new
    assert_equal [1],# [[0,1],[2]],
      cz.get_attach_idxs(loc_source, loc_target)
    loc_source = [0.1, 0.2, 0.3]
    assert_equal [1], #[[0,1],[2]],
      cz.get_attach_idxs(loc_source, loc_target)
    loc_source = [0.1, 0.7, 0.8]
    assert_equal [2], #[[0],[1,2]],
      cz.get_attach_idxs(loc_source, loc_target)
  end
end
