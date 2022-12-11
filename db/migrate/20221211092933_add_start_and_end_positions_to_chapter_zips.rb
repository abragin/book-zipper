class AddStartAndEndPositionsToChapterZips < ActiveRecord::Migration[6.1]
  def change
    change_table :chapter_zips do |t|
      t.integer :start_position_source, nil: false, default: 0
      t.integer :end_position_source, nil: true
      t.integer :start_position_target, nil: false, default: 0
      t.integer :end_position_target, nil: true
    end
  end
end
