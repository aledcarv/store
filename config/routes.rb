require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  resource :cart, only:  %i[show update] do
    delete '/:product_id', to: 'carts#destroy'
    resource :add_item, only: %i[update]
  end
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
