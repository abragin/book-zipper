require "test_helper"

class ChapterZipTest < ActiveSupport::TestCase
  test '#build_paragraph_matches' do
    new_cz = ChapterZip.create(
      book_zip: book_zips(:bookzipone),
      source_chapter: chapters(:one),
      target_chapter: chapters(:two)
    )
    assert_equal "chapter_one - chapter_two", new_cz.title
    assert_equal 2, new_cz.paragraph_matches.length
  end

  test '#process_zip_info' do
    cz = chapter_zips(:one)
    cz.zip_info = {
      'source' => {'attach_ids' => [cz.source_ps[2].id.to_s]},
      'target' => {'attach_ids' => [cz.target_ps[1].id.to_s]}
    }
    cz.process_zip_info
    expected = {
      'source' => {'attach_ids' => [cz.source_ps[1].id, cz.source_ps[2].id]},
      'target' => {'attach_ids' => [cz.target_ps[1].id]}
    }
    assert_equal [cz.target_ps[1].id], cz.zip_info['target']['attach_ids']
    assert_equal 2, cz.zip_info['source']['attach_ids'].length
    assert_includes cz.zip_info['source']['attach_ids'], cz.source_ps[1].id
    assert_includes cz.zip_info['source']['attach_ids'], cz.source_ps[2].id
  end

  test '#build_groupped_ps' do
    z_inf = {'attach_ids' => [chapters(:one).paragraphs[1].id]}
    bgp_res = ChapterZip.new.build_groupped_ps(chapters(:one).paragraphs, z_inf)
    assert_equal 2, bgp_res.length
    assert_equal 2, bgp_res[0].length
    assert_equal 1, bgp_res[1].length
  end

  test '#build_default_zip_info' do
    cz = ChapterZip.new(
      book_zip: book_zips(:bookzipone),
      source_chapter: chapters(:one),
      target_chapter: chapters(:two)
    )
    expected_zi = {
      'source' => {'attach_ids' => [paragraphs(:one_sentence_paragraph).id]},
      'target' => {'attach_ids' => []},
    }
    cz.build_default_zip_info
    assert_equal expected_zi, cz.zip_info
  end

end
