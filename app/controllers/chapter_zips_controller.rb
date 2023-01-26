class ChapterZipsController < ApplicationController
  def new
    @book_zip = BookZip.find(params[:book_zip_id])
    @chapter_zip = ChapterZip.new(book_zip: @book_zip)
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
    @chapter_zip = ChapterZip.find(params[:id])
  end

  def update
    @chapter_zip = ChapterZip.find(params[:id])
    if params['chapter_zip']['zip_info'].blank?
      @chapter_zip.zip_info = {}
    end
    if @chapter_zip.update(chapter_zip_params)
      if params[:update_and_create]
        next_chapter = @chapter_zip.next_chapter_zip
        if next_chapter && next_chapter.save
          redirect_to edit_book_zip_chapter_zip_path(
            next_chapter.book_zip, next_chapter)
        else
          flash.alert = 'New ChapterZip creation failed'
          render :edit
        end
      else
        redirect_to edit_book_zip_chapter_zip_path(
          @chapter_zip.book_zip, @chapter_zip)
      end
    else
      render :edit
    end
  end

  def destroy
    @chapter_zip = ChapterZip.find(params[:id])
    @chapter_zip.destroy

    redirect_to @chapter_zip.book_zip
  end

  private

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
