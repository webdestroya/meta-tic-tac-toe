MetaTicTacToe::Application.routes.draw do
  
  resources :games, only: [:new, :create, :update, :show]

  get 'about', to: 'pages#about'

  post 'pusher/auth', to: 'pages#pusher_auth'

  root to: 'pages#index'
end
