Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #get "/epub_books", to: "epub_books#index"
  root "epub_books#index"

  resources :book_zips, only: [:index, :new, :create, :show] do
    resources :chapter_zips, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :epub_books do
    resources :epub_items, only: [:show]
    resources :chapters, only: [:index, :show, :update]
    member do
      post :create_chapters
      post :update_ignored_paragraphs
      get :filter_paragraphs
    end
  end
end
