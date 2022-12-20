module BreakFinder
  def find_breaks(ws1, ws2)
    # input - weights of different partitions
    # ouptut two lists with indexes of breaks between weights that should be
    # merged together

  end

  def self.get_nearest_blocks(ws1, ws2)
    ps1 = block_center_positions(ws1)
    ps2 = block_center_positions(ws2)

  end

  def self.get_nearest_positions(ps1, ps2)
    # returns a list of indexes of nearest position in ps2
    # for each position in ps1
    # assumes ascending order for both ps1 and ps2
    nps = []
    coursor = 0
    ps1.each do |p|
      d1 = ps2[coursor] - p
      should_cont = (coursor < (ps2.length - 1)) && (d1<0)
      d1 = d1.abs
      while should_cont do
        d2 = ps2[coursor+1] - p
        if d2 > 0
          if d1 > d2.abs
            coursor += 1
          end
          should_cont = false
        else
          coursor += 1
          should_cont = coursor < (ps2.length - 1)
        end
      end
      nps.append(coursor)
    end
    nps
  end

  def self.nearest_position_distances(ps1, ps2, nps1)
    # distances from each element of ps1 to nearest element in ps2
    # nps1 should be the result of get_nearest_positions(ps1, ps2)
    ps1.each_with_index.map do |p, i|
      (p - ps2[nps1[i]]).abs
    end
  end

  def self.block_size_distances(bs1, bs2, nps1)
    bs1.each_with_index.map do |bs, i|
      (bs - bs2[nps1[i]]).abs
    end
  end

  def self.break_positions(weights)
    weights[1...-1].reduce([weights[0]]) do |acc, w|
      acc.append(acc[-1] + w)
    end
  end

  def self.block_center_positions(weights)
    locs = [weights[0]/2.0]
    pos = [weights[0]]
    weights[1..].each do |w|
      locs.append(pos[-1] + w/2.0)
      pos.append(pos[-1] + w)
    end
    locs
  end
end
