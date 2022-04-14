# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :v1, module: 'v1' do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      sessions: 'v1/auth/sessions',
      registrations: 'v1/auth/registrations'
    }
    resources :hello, only: %i[index show]
    resources :items
    get  'market', to: 'market#show'
    post 'market/buy/:item_id', to: 'market#buy', as: 'market_buy'
  end
end
