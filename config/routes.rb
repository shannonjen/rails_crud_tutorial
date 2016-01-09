Rails.application.routes.draw do
  root 'albums#index'
  resources :albums
end
