Rails.application.routes.draw do

  get '/verify_code', to: 'invitations#verify_code'
  resources :invitations
  
  resources :missions

  devise_for(:users, :controllers => { :sessions => "session/sessions"})
  root 'welcome#index'

  resources :welcome do
    collection do
      get 'dashboard'
    end
  end
  resources :users

  resources :users_admin, :controller => 'users'

end
