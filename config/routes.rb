Rails.application.routes.draw do
  devise_for :users

  # マイページ用ルーティング (/mypage)
  resource :mypage, only: [ :show ]
  resource :omikuji, only: [ :show ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  # 🎴 絶望百人一首（かるた）
  get "karuta", to: "karuta#show"
  post "karuta/results", to: "karuta_results#create", as: :karuta_results
  # 🎴 合言葉の部屋（2人対戦）
  post "karuta/rooms", to: "karuta_rooms#create", as: :karuta_rooms
  get "karuta/rooms/join", to: "karuta_rooms#join", as: :join_karuta_room
  get "karuta/rooms/:code", to: "karuta_rooms#show", as: :karuta_room

  # ⏳ 絶望年表（タイムライン）
  get "timeline", to: "posts#timeline"

  # :edit, :update, :destroy を追加
  resources :posts, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    member do
      get :ogp, defaults: { format: :png }
      post :like
    end
  end

  # 📜 静的ページ（利用規約・プライバシーポリシー）
  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"
end
