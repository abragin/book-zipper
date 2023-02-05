class BookZipsController < ApplicationController
  before_action :set_book_zip, only: %i[ show destroy ]

  def index
    @book_zips = BookZip.all
  end

  def new
    @book = Book.find(params[:book_id])
    @book_zip = BookZip.new
  end

  def create
    @book = Book.find(params[:book_id])
    @book_zip = BookZip.new(book_zip_params)
    if @book_zip.save
      redirect_to @book_zip
    else
      render :new
    end
  end

  def show
  end

  def destroy
    @book_zip.destroy

    respond_to do |format|
      format.html { redirect_to book_zips_url, notice: "Book zip was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_book_zip
    @book_zip = BookZip.find(params[:id])
  end

  def book_zip_params
    params.require(:book_zip).permit(
      :ebook_source_id, :ebook_target_id
     )
  end
end
