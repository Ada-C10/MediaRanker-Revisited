Rails.application.routes.draw do
  get "/auth/:provider/callback", to: "sessions#create", as: 'auth_callback'
  delete "/logout", to: "sessions#destroy", as: "logout"


  root 'works#root'

  resources :works
  post '/works/:id/upvote', to: 'works#upvote', as: 'upvote'

  resources :users, only: [:index, :show]
end
