MetaTicTacToe::Application.routes.draw do
  
  resources :games, only: [:new, :create, :update, :show]

  get 'rules', to: 'pages#rules'

  post 'pusher/auth', to: 'pages#pusher_auth'

  root to: 'pages#index'
end
