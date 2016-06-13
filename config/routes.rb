Rails.application.routes.draw do
  # resources :comments
  # resources :photos
  resources :tags
  put 'login', to: 'users#login'
  put 'i_want_to_go/:id', to: 'users#i_want_to_go'
  post 'sociallogin', to: 'users#create'
  post 'registration', to: 'users#create'
  post 'recovery', to: 'users#recovery'
  get 'events/:event_id/participants', to: 'users#index'
  resources :users
  get 'events/:event_id/comments', to: 'comments#index'
  resources :events do
    resources :photos
    resources :comments
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
