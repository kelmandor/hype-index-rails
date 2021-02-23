Rails.application.routes.draw do
  require 'sidekiq/web'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :study
  resources :frontend do
    collection  do
      get :assets_list
    end

    member do
      get :asset
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'
end
