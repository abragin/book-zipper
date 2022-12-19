class ChaptersController < ApplicationController
  def index
    @epub_book = EpubBook.find(params[:epub_book_id])
    @chapters = @epub_book.chapters.includes(:paragraphs)
  end

  def show
    @chapter = Chapter.find(params[:id])
    @epub_book = @chapter.epub_book
  end

  def update
    @chapter = Chapter.find(params[:id])
    @chapter.paragraphs.where(id: chapter_params[:ignore_paragraph_ids]
                             ).update_all(ignore: true)
    @chapter.paragraphs.where.not(id: chapter_params[:ignore_paragraph_ids]
                             ).update_all(ignore: false)
    redirect_to [@chapter.epub_book, @chapter]
  end

  def chapter_params
    params.require(:chapter).permit(
      ignore_paragraph_ids: []
    )
  end

end
