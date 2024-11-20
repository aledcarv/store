require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  resource :cart
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
