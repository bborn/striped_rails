StripedRails::Engine.routes.draw do
  
  root to: 'pages#index'

  resources :users
  
  get '/subscribe' => 'users#subscribe', :as => 'subscribe'
  post '/subscribe' => 'users#create_subscription', as: 'create_subscription'


  resource :profile, only: [:show,:edit,:update]
  
  resource :credit_card, only: [:new,:create]
  resource :subscription, only: [:update,:destroy]
  resource :dashboard, only: [:show]
  resources :subscription_plans, only: [:index,:edit,:update] do
    collection do
      get :available
    end
  end
  
  resources :coupons, only: [:index,:edit,:update]
  resources :coupon_subscription_plans, only: [:create,:destroy]
  resources :webhooks, only: :create
  resources :pages

end
