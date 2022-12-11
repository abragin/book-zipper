class BookZipsController < ApplicationController
  def new
    @book_zip = BookZip.new
  end

  def create
    @book_zip = BookZip.new(book_zip_params)
    if @book_zip.save
      redirect_to @book_zip
    else
      render :new
    end
  end

  def show
    @book_zip = BookZip.find(params[:id])
  end

  private

  def book_zip_params
    params.require(:book_zip).permit(
      :ebook_source_id, :ebook_target_id
     )
  end
end
