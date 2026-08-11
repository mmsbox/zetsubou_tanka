Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check

  # TOPページを root に設定
  root "home#index"

  resources :posts, only: [:index, :show, :new, :create]
end
