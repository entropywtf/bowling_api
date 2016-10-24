Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'games/start', to: 'games#create'
  get 'games/:id/', to: 'games#score'
  post 'games/:id/', to: 'games#score'
end
