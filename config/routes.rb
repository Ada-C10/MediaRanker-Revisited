Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'works#root'
  resources :works
  post '/works/:id/upvote', to: 'works#upvote', as: 'upvote'

  resources :users, only: [:index, :show]

  get '/auth/github', to: 'sessions#login_form', as: 'login'
  get "/auth/:provider/callback", to: "sessions#create", as: 'auth_callback'

  post '/login', to: 'sessions#login'
  
  delete "/logout", to: "sessions#destroy", as: "logout"



end
