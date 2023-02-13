class EpubItemsController < ApplicationController
  def show
    @epub_item = EpubItem.find(params[:id])
  end

  def edit
    @epub_item = EpubItem.find(params[:id])
    @epub_book = @epub_item.epub_book
  end

  def update
    @epub_item = EpubItem.find(params[:id])
    @epub_book = @epub_item.epub_book
    if @epub_item.update(epub_item_params)
      redirect_to epub_book_epub_item_path(@epub_book, @epub_item)
    else
      render :edit
    end
  end

  private

    def epub_item_params
      params.require(:epub_item).permit(:content)
    end
end
