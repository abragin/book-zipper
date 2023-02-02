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

  def filter_paragraphs
    @epub_book = EpubBook.find(params[:id])
    if params.include? 'paragraph_search'
      @search = paragraph_search_params
    else
      @search = {}
    end
    if @search
      @paragraphs = @epub_book.paragraphs
      if @search['not_ignored']
        @paragraphs = @paragraphs.where(ignore: false)
      end
      if @search['ignored']
        @paragraphs = @paragraphs.where(ignore: true)
      end
      if @search['has_no_words']
        @paragraphs = @paragraphs.filter{|p| p.content.split.size == 0}
      end
      if @search['regexp'].present?
        r = Regexp.new @search['regexp']
        @paragraphs = @paragraphs.filter{|p| p.content.match r}
      end
      @paragraphs = @paragraphs.limit(200)
    else
      @paragraphs = []
    end
  end

  def update_ignored_paragraphs
    @epub_book = EpubBook.find(params[:id])
    p = ignore_paragraphs_params
    if p[:ignore_all_paragraphs]
      @epub_book.paragraphs.where(
        'paragraphs.id IN (?)', p[:current_paragraphs_ids]
      ).update_all(ignore: true)
    else
      @epub_book.paragraphs.where(
        'paragraphs.id IN (?)', p[:ignored_paragraphs_ids]
      ).update_all(ignore: true)
    end
    redirect_back(fallback_location: root_path)
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

  def ignore_paragraphs_params
    params.permit(
      :ignore_all_paragraphs,
      current_paragraphs_ids: [],
      ignored_paragraphs_ids: []
    )
  end

  def paragraph_search_params
    params.require(:paragraph_search).permit(
      :regexp, :not_ignored, :ignored, :has_no_words
     )
  end

  def book_params
    params.require(:epub_book).permit(
      :file, :title, :content_location, :title_tags_text, :content_tag,
      :excluded_content_tag, :start_position, :end_position, :book_id,
      :language_id
     )
  end
end
