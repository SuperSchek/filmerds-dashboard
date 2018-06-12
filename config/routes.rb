Rails.application.routes.draw do
  resources :uploads, only: [:new, :create]
  
  # LocomotiveCMS API
  post '/submit_podcast', to: 'locomotive#submit_podcast'
end
