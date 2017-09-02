Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :comments
  resources :dashboard, only: %i(index)

  root "dashboard#index"
end
