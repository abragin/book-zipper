class ChaptersController < ApplicationController
  def index
    @epub_book = EpubBook.find(params[:epub_book_id])
    @chapters = @epub_book.chapters.includes(:paragraphs)
  end

  def show
    @chapter = Chapter.find(params[:id])
    @epub_book = @chapter.epub_book
  end
end
