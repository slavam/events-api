Rails.application.routes.draw do
  resources :comments
  # resources :photos
  resources :tags
  put 'login', to: 'users#login'
  put 'i_want_to_go/:id', to: 'users#i_want_to_go'
  post 'registration', to: 'users#create'
  resources :users
  resources :events do
    resources :photos
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
