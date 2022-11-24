Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #get "/epub_books", to: "epub_books#index"
  root "epub_books#index"

  resources :epub_books do
    resources :epub_items, only: [:show]
  end
end
