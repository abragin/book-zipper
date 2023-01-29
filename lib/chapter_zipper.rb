require "matrix"

class ChapterZipper
  #attr_reader :source_weights, :target_weights, :merged_source_idx,
    #:merged_target_idx, :source_m
  attr_reader :current_source_weights, :current_target_weights,
    :current_c_source_weights, :current_c_target_weights,
    :res_pointer, :s_pointer, :t_pointer, :merged_source_idx,
    :merged_target_idx

  def initialize(source_weights, target_weights)
    @source_weights = source_weights.map{|w| if w > 0 then w else 1.0e-10 end}
    @target_weights = target_weights.map{|w| if w > 0 then w else 1.0e-10 end}
    @merged_source_idx = Set[]
    @merged_target_idx = Set[]
    @source_mapping = Array(0..source_weights.length)
    @target_mapping = Array(0..target_weights.length)
    @current_source_weights = @source_weights.clone()
    @current_target_weights = @target_weights.clone()
    @current_c_source_weights = c_weights(@source_weights)
    @current_c_target_weights = c_weights(@target_weights)
    @res_pointer = 0
    @s_pointer = 1
    @t_pointer = 1
  end

  def merge_source
    add_merge_points(@s_pointer, nil)
    @s_pointer += 1
  end

  def merge_target
    add_merge_points(nil, @t_pointer)
    @t_pointer += 1
  end

  def no_merge
    @t_pointer += 1
    @s_pointer += 1
    @res_pointer += 1
  end

  def c_weights(weights)
    res = [weights[0]]
    for w in weights[1..]
        res.append(res[-1] + w)
    end
    res
  end

  def weights_after_merge(si, ti)
    if si && (si < @source_weights.size)
      si_mapped = @source_mapping[si]
      new_c_s_weights = @current_c_source_weights[...si_mapped-1] +
        @current_c_source_weights[si_mapped..]
      new_weight = @current_source_weights[si_mapped-1..si_mapped].sum
      new_s_weights = @current_source_weights[...si_mapped-1] + [new_weight] +
        @current_source_weights[si_mapped+1..]
    else
      new_c_s_weights = @current_c_source_weights
      new_s_weights = @current_source_weights
    end
    if ti && (ti < @target_weights.size)
      ti_mapped = @target_mapping[ti]
      new_c_t_weights = @current_c_target_weights[...ti_mapped-1] +
        @current_c_target_weights[ti_mapped..]
      new_weight = @current_target_weights[ti_mapped-1..ti_mapped].sum
      new_t_weights = @current_target_weights[...ti_mapped-1] + [new_weight] +
        @current_target_weights[ti_mapped+1..]
    else
      new_c_t_weights = @current_c_target_weights
      new_t_weights = @current_target_weights
    end
    {
      new_c_s: new_c_s_weights,
      new_c_t: new_c_t_weights,
      new_s_w: new_s_weights,
      new_t_w: new_t_weights
    }
  end

  def metrics(s_ws, t_ws, c_s_ws, c_t_ws)
    s_ws_r = s_ws[self.res_pointer+1..self.res_pointer+4]
    t_ws_r = t_ws[self.res_pointer+1..self.res_pointer+4]
    if s_ws_r == []
      s_ws_r = [1.0e-8]
    end
    if t_ws_r == []
      t_ws_r = [1.0e-8]
    end

    if s_ws_r.length < t_ws_r.length
      t_ws_r[s_ws_r.length-1..] = [t_ws_r[s_ws_r.size-1..].sum]
    end
    if t_ws_r.size < s_ws_r.size
      s_ws_r[t_ws_r.length-1..] = [s_ws_r[t_ws_r.size-1..].sum]
    end

    w_distance = Math.log(
        s_ws[self.res_pointer] / t_ws[self.res_pointer]
    ).abs
    w_distance_after = s_ws_r.zip(t_ws_r).filter(&:all?).map do |sw, tw|
      Math.log(sw/tw).abs
    end.sum / t_ws_r.size
    c_weights_zip = c_s_ws[@res_pointer..@res_pointer+5].zip(
      c_t_ws[@res_pointer..@res_pointer+5]
    ).filter(&:all?)
    c_distance_after = c_weights_zip.map do |sw, tw|
      (sw-tw).abs
    end.sum / c_weights_zip.size
    [w_distance, w_distance_after, c_distance_after]
  end

  def next_merge
    if (@s_pointer == @source_weights.size) && (@t_pointer == @target_weights.size)
      return
    elsif (@s_pointer == @source_weights.size) && (@t_pointer < @target_weights.size)
      return 'T'
    elsif (@s_pointer < @source_weights.size) && (@t_pointer == @target_weights.size)
      return 'S'
    else
      weights_s_m = weights_after_merge(@s_pointer, nil)
      weights_t_m = weights_after_merge(nil, @t_pointer)
      metrics_current = metrics(
        @current_source_weights, @current_target_weights,
        @current_c_source_weights, @current_c_target_weights
      )
      metrics_s_m = metrics(
        weights_s_m[:new_s_w], weights_s_m[:new_t_w],
        weights_s_m[:new_c_s], weights_s_m[:new_c_t]
      )
      metrics_t_m = metrics(
        weights_t_m[:new_s_w], weights_t_m[:new_t_w],
        weights_t_m[:new_c_s], weights_t_m[:new_c_t]
      )
      merge_source_score = classifier(
        Vector.elements(metrics_current + metrics_s_m)
      )
      merge_target_score = classifier(
        Vector.elements(metrics_current + metrics_t_m)
      )
      if [merge_source_score, merge_target_score].min > 0
        if merge_source_score > merge_target_score
          return 'S'
        else
          return 'T'
        end
      elsif merge_source_score > 0
        return 'S'
      elsif merge_target_score > 0
        return 'T'
      else
        return 'N'
      end
    end
  end

  def get_merge_idx
    while n_m = next_merge
      case n_m
      when 'S'
        merge_source
      when 'T'
        merge_target
      else
        no_merge
      end
    end
    [@merged_source_idx.sort, @merged_target_idx.sort]
  end

  def add_merge_points(si, ti)
    new_weights = weights_after_merge(si, ti)
    if si
      @merged_source_idx.add(si)
      si.upto(@source_mapping.length - 1) do |i|
        @source_mapping[i] -= 1
      end
      @current_source_weights = new_weights[:new_s_w]
      #res_weights(
        #source_weights, @merged_source_idx
      #)
      @current_c_source_weights = new_weights[:new_c_s]
      #c_weights(@current_source_weights)
    end
    if ti
      @merged_target_idx.add(ti)
      ti.upto(@target_mapping.length - 1) do |i|
        @target_mapping[i] -= 1
      end
      @current_target_weights = new_weights[:new_t_w]
      #res_weights(
        #@target_weights, @merged_target_idx
      #)
      @current_c_target_weights = new_weights[:new_c_t]
      #c_weights(@current_target_weights)
    end
  end

  def classifier(x)
    scaler_mean = Vector[
      0.1860575 , 0.28707439, 0.01254617, 0.82783402, 1.26658851, 0.02764434
    ]
    scaler_scale = Vector[
      0.24838857, 0.33084664, 0.01216887, 0.65755263, 2.17709204, 0.02135905
    ]
    cls_coef = Vector[
      1.57098274,  0.58236663,  0.89874209,
      -3.76852604, -2.00030208, -1.06507971
    ]
    cls_intercept = -8.68506419
    x_scaled = (x - scaler_mean).map2(scaler_scale) {|x1,x2| x1 / x2}
    pred = x_scaled.dot(cls_coef) + cls_intercept
    pred
  end
end
