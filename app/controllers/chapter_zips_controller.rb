class ChapterZipsController < ApplicationController
  before_action :set_chapter_zip,
    only: %i[ edit edit_matching update_matching update destroy ]

  def new
    @book_zip = BookZip.find(params[:book_zip_id])
    if params[:prev_chapter_id]
      prev_chapter = ChapterZip.find(params[:prev_chapter_id])
      next_chapter = prev_chapter.next_chapter_zip
      if next_chapter && next_chapter.save
        redirect_to edit_book_zip_chapter_zip_path(
          next_chapter.book_zip, next_chapter)
      else
        flash.alert = 'New ChapterZip creation failed'
        @chapter_zip = ChapterZip.new(book_zip: @book_zip)
      end
    else
      @chapter_zip = ChapterZip.new(book_zip: @book_zip)
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

  def edit
  end

  def edit_matching
  end

  def update_matching
    @chapter_zip.matching_data = params['matching_data']
    if @chapter_zip.save
      redirect_to edit_book_zip_chapter_zip_path(
          @chapter_zip.book_zip, @chapter_zip)
    else
      flash.alert = 'Update failed!'
      render :edit_matching
    end
  end

  def update
    if @chapter_zip.update(chapter_zip_params)
      redirect_to edit_book_zip_chapter_zip_path(
        @chapter_zip.book_zip, @chapter_zip)
    else
      flash.alert = 'Update failed!'
      render :edit
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

  def chapter_zip_params
    params.require(:chapter_zip).permit(
      :source_chapter_id, :target_chapter_id, :start_position_source,
      :start_position_target, :end_position_source, :end_position_target,
      :position, :book_zip_id,
      zip_info: [
        source:  [
          attach_ids: [],
          ignore_ids: []
        ],
        target: [
          attach_ids: [],
          ignore_ids: []
        ]
      ]
    )
  end
end
