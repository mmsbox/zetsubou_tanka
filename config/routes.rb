Rails.application.routes.draw do
  devise_for :users

  # マイページ用ルーティング (/mypage)
  resource :mypage, only: [ :show ]
  resource :omikuji, only: [ :show ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  # :edit, :update, :destroy を追加
  resources :posts, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    member do
      get :ogp, defaults: { format: :png }
      post :like
    end
  end
end
