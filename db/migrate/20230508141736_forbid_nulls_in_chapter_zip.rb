class ForbidNullsInChapterZip < ActiveRecord::Migration[7.0]
  def change
    change_column_null :chapter_zips, :book_zip_id, false
    change_column_null :chapter_zips, :position, false
    change_column_null :chapter_zips, :source_chapter_id, false
    change_column_null :chapter_zips, :target_chapter_id, false
    change_column_null :chapter_zips, :start_position_source, false
    change_column_null :chapter_zips, :start_position_target, false
    change_column_null :chapter_zips, :end_position_source, false
    change_column_null :chapter_zips, :end_position_target, false
  end
end
