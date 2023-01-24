require "test_helper"

class ChapterZipperTest < ActiveSupport::TestCase
  #include ChapterZipper
  def assert_array_in_delta(d, exp, res)
    assert_equal exp.size, res.size
    exp.zip(res).each do |e, r|
      assert_in_delta d, e, r
    end
  end

  source_weights = [0.35, 0.3, 0.15, 0.2]
  target_weights = [0.3, 0.2, 0.15, 0.35]

  test "zipping process" do
    zipper = ChapterZipper.new(source_weights, target_weights)
    metrics = zipper.metrics(
      zipper.current_source_weights,
      zipper.current_target_weights,
      zipper.current_c_source_weights,
      zipper.current_c_target_weights
    )
    assert_array_in_delta 0.0001,
      [0.15415, 0.3217, 0.0875],
      metrics
    w_a_m = zipper.weights_after_merge(1,1)
    assert_array_in_delta 0.0001, [0.65, 0.15, 0.2], w_a_m[:new_s_w]
    assert_array_in_delta 0.0001, [0.5, 0.15, 0.35], w_a_m[:new_t_w]
    assert_array_in_delta 0.0001, [0.65, 0.8, 1.0], w_a_m[:new_c_s]
    assert_array_in_delta 0.0001, [0.5, 0.65, 1.0], w_a_m[:new_c_t]
    metrics_s_m = zipper.metrics(
      w_a_m[:new_s_w],
      zipper.current_target_weights,
      w_a_m[:new_c_s],
      zipper.current_c_target_weights
    )
    assert_array_in_delta 0.0001,
      [0.7732, 0.6020, 0.3333],
      metrics_s_m
    metrics_t_m = zipper.metrics(
      zipper.current_source_weights,
      w_a_m[:new_t_w],
      zipper.current_c_source_weights,
      w_a_m[:new_c_t],
    )
    assert_array_in_delta 0.0001,
      [0.3567, 0.3466, 0.1167],
      metrics_s_m
    assert zipper.classifier(Vector.elements(metrics + metrics_s_m)) < 0
    assert zipper.classifier(Vector.elements(metrics + metrics_t_m)) < 0
    assert_equal 'N', zipper.next_merge
    zipper.no_merge
    assert_equal 'T', zipper.next_merge
    zipper.merge_target
    assert_equal 'N', zipper.next_merge
    zipper.no_merge
    assert_equal 'S', zipper.next_merge
    zipper.merge_source
    assert_equal Set[3], zipper.merged_source_idx
    assert_equal Set[2], zipper.merged_target_idx
  end

  test "#get_merge_idx" do
    zipper = ChapterZipper.new(source_weights, target_weights)
    assert_equal [[3], [2]], zipper.get_merge_idx
  end
end
