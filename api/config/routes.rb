Rails.application.routes.draw do
  namespace :v1 do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      sessions: 'v1/auth/sessions',
      registrations: 'v1/auth/registrations'
    }
    resources :hello, only:[:index]
  end
end
