Rails.application.routes.draw do
  put 'login', to: 'users#login'
  post 'registration', to: 'users#create'
  resources :users
  resources :eventsd
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
