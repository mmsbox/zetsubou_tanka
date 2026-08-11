Rails.application.routes.draw do
  devise_for :users

  # マイページ用ルーティング (/mypage)
  resource :mypage, only: [:show]

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :posts, only: [:index, :show, :new, :create]
end
