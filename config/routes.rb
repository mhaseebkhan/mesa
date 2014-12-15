Rails.application.routes.draw do

  get '/verify_code', to: 'invitations#verify_code'
  get '/get_mission_invites', to: 'missions#get_mission_invites'
  get '/get_working_missions', to: 'missions#get_working_missions'
  get '/get_mission_details', to: 'missions#get_mission_details'
  put '/reset_password', to: 'users#reset_password'
 
  resources :invitations
  resources :missions

  devise_for(:users, :controllers => { :sessions => "session/sessions", :registrations => "session/registrations"})

  root 'welcome#index'

  resources :welcome do
    collection do
      get 'dashboard'
    end
  end
  resources :users

  resources :users_admin, :controller => 'users'

end
