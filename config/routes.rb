Rails.application.routes.draw do
  devise_for :users

  # マイページ用ルーティング (/mypage)
  resource :mypage, only: [ :show ]
  resource :omikuji, only: [ :show ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :posts, only: [ :index, :show, :new, :create ] do
    member do
    get :ogp, defaults: { format: :png, :jpg }
    post :like
    end
  end
end
