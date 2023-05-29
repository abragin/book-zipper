class ChapterZipsController < ApplicationController
  before_action :set_chapter_zip,
    only: %i[ edit change_paragraph_ranges update_ranges update destroy ]

  def new
    @book_zip = BookZip.find(params[:book_zip_id])
    if params[:prev_chapter_id]
      prev_chapter = ChapterZip.find(params[:prev_chapter_id])
      next_chapter = prev_chapter.build_next_chapter_zip
      if next_chapter && next_chapter.save
        redirect_to edit_book_zip_chapter_zip_path(
          next_chapter.book_zip, next_chapter)
      else
        flash.alert = 'New ChapterZip creation failed'
        @chapter_zip = ChapterZip.new(book_zip: @book_zip)
      end
    else
      mpos = @book_zip.chapter_zips.maximum(:position)
      pos = mpos ? mpos + 1 : 0
      @chapter_zip = ChapterZip.new(book_zip: @book_zip, position: pos)
    end
  end

  def create
    @chapter_zip = ChapterZip.new(chapter_zip_params)
    if @chapter_zip.save
      redirect_to edit_book_zip_chapter_zip_path(
        @chapter_zip.book_zip,
        @chapter_zip
      )
    else
      render :new
    end
  end

  def update
    @chapter_zip.update(chapter_zip_edit_params)
    if params["rematch_from_here"]
      @chapter_zip.rebuild_zip_info
      @chapter_zip.save!
      redirect_to edit_book_zip_chapter_zip_path(
          @chapter_zip.book_zip, @chapter_zip)
    else
      @chapter_zip.zip_info["verified_connection_source_id"] = nil
      @chapter_zip.zip_info["inconsistent_connection_source_id"] = nil
      @chapter_zip.zip_info["unverified_connection_source_ids"] = []
      if @chapter_zip.save
        if params['update_and_build_next'] &&
            @chapter_zip.build_next_chapter_zip.present?
          redirect_to new_book_zip_chapter_zip_path(
            @chapter_zip.book_zip,
            prev_chapter_id: @chapter_zip.id
          )
        else
          redirect_to edit_book_zip_chapter_zip_path(
              @chapter_zip.book_zip, @chapter_zip)
        end
      else
        flash.alert = 'Update failed!'
        render :edit
      end
    end
  end

  def update_ranges
    if @chapter_zip.update(chapter_zip_params)
      redirect_to edit_book_zip_chapter_zip_path(
        @chapter_zip.book_zip, @chapter_zip)
    else
      flash.alert = 'Update failed!'
      render :change_paragraph_ranges
    end
  end

  def destroy
    @chapter_zip.destroy

    redirect_to @chapter_zip.book_zip
  end

  private

  def set_chapter_zip
    @chapter_zip = ChapterZip.find(params[:id])
  end

  def chapter_zip_edit_params
    params.require(:chapter_zip).permit(
      :position, :matching_data
    )

  end

  def chapter_zip_params
    params.require(:chapter_zip).permit(
      :source_chapter_id, :target_chapter_id, :start_position_source,
      :start_position_target, :end_position_source, :end_position_target,
      :position, :book_zip_id
    )
  end
end
