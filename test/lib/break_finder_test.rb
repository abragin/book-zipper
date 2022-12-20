require "test_helper"

class BreakFinderTest < ActiveSupport::TestCase

   test ".break_positions" do
     weights = [0.1,0.3,0.6]
     assert_equal [0.1, 0.4], BreakFinder.break_positions(weights)
   end

   test ".block_center_positions" do
     weights = [0.1,0.3,0.6]
     assert_equal [0.05, 0.25, 0.7], BreakFinder.block_center_positions(weights)
   end

   test ".get_nearest_positions" do
     positions1 = [0.1, 0.4]
     positions2 = [0.15, 0.3, 0.8]
     assert_equal [0, 1], BreakFinder.get_nearest_positions(positions1, positions2)
     assert_equal [0, 1, 1], BreakFinder.get_nearest_positions(positions2, positions1)
   end

   test ".nearest_position_distances" do
     ws1 = [0.3, 0.7]
     ws2 = [0.2, 0.2, 0.6]
     ps1 = BreakFinder.block_center_positions(ws1)
     ps2 = BreakFinder.block_center_positions(ws2)
     nps1 = BreakFinder.get_nearest_positions(ps1, ps2)
     nps2 = BreakFinder.get_nearest_positions(ps2, ps1)

     assert_equal [(ws1[0]-ws2[0]).abs, (ws1[1]- ws2[2]).abs],
       BreakFinder.nearest_position_distances(ws1, ws2, nps1)
     assert_equal [(ws1[0]-ws2[0]).abs, (ws1[0]- ws2[1]).abs, (ws1[1]- ws2[2]).abs],
       BreakFinder.nearest_position_distances(ws2, ws1, nps2)
   end
end
