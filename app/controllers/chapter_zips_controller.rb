class ChapterZipsController < ApplicationController
  def new
    @book_zip = BookZip.find(params[:book_zip_id])
    @chapter_zip = ChapterZip.new(book_zip: @book_zip)
  end

  def create
    @chapter_zip = ChapterZip.new(chapter_zip_params)
    @chapter_zip.build_paragraph_matches
    if @chapter_zip.save
      redirect_to @chapter_zip.book_zip
    else
      render :new
    end
  end

  def edit
    @chapter_zip = ChapterZip.find(params[:id])
  end

  def update
    binding.pry
    print 1
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
      :position, :book_zip_id
     )
  end
end
