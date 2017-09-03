Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :comments
  resources :dashboard, only: %i(index)

  root "dashboard#index"
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], as: :finish_signup
  match '/users/:id', to: 'users#show', via: 'get', as: :user
end
