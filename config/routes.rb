MetaTicTacToe::Application.routes.draw do
  
  resources :games, only: [:new, :update, :show] do
    get 'expire', action: :expire, on: :member
  end

  get 'rules', to: 'pages#rules'

  post 'pusher/auth', to: 'pages#pusher_auth'

  root to: 'pages#index'
end
