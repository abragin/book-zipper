class EpubBooksController < ApplicationController
  def index
    @epub_books = EpubBook.all
  end

  def new
    @epub_book = EpubBook.new
  end

  def create
    @epub_book = EpubBook.new(book_params)
    if @epub_book.save
      redirect_to @epub_book
    else
      render :new
    end
  end

  def show
    @epub_book = EpubBook.find(params[:id])
  end

  def edit
    @epub_book = EpubBook.find(params[:id])
  end

  def update
    @epub_book = EpubBook.find(params[:id])
    if @epub_book.update(book_params)
      redirect_to @epub_book
    else
      render :edit
    end
  end

  def destroy
    @epub_book = EpubBook.find(params[:id])
    @epub_book.destroy

    redirect_to epub_books_path
  end

  def create_chapters
    @epub_book = EpubBook.find(params[:id])
    @epub_book.store_structured
    redirect_to epub_book_chapters_path(@epub_book)
  end

  private

  def book_params
    params.require(:epub_book).permit(
      :file, :title, :content_location, :title_tags_text, :content_tag,
      :excluded_content_tag, :start_position, :end_position
     )
  end
end
