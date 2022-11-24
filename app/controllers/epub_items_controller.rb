class EpubItemsController < ApplicationController
  def show
    @epub_item = EpubItem.find(params[:id])
  end
end
