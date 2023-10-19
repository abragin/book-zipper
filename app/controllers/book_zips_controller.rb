class BookZipsController < ApplicationController
  before_action :set_book_zip, only: %i[ show destroy ]

  def index
    @book_zips = BookZip.all
  end

  def new
    @book = Book.find(params[:book_id])
    @book_zip = BookZip.new
  end

  def export
    bz_ids = export_book_zips_params[:book_zips_ids]
    stringio = Zip::OutputStream.write_buffer do |stream|
      bz_ids.each do |bz_id|
        book_zip = BookZip.find(bz_id)
        f_name = book_zip.title
        author = book_zip.ebook_source.book.author.name

        stream.put_next_entry("#{author}/#{f_name}.json")
        stream.write JSON.dump(book_zip.export_hash)
      end
    end
    send_data(
      stringio.string,
      :filename => "book_zips.zip",
      :type => 'application/zip'
    )
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

  def export_book_zips_params
    params.permit(
      book_zips_ids: []
    )
  end
end
