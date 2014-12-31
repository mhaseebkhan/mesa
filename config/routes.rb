Rails.application.routes.draw do

  get '/verify_code', to: 'invitations#verify_code'
  get '/get_mission_invites', to: 'missions#get_mission_invites'
  get '/get_working_missions', to: 'missions#get_working_missions'
  get '/get_mission_details', to: 'missions#get_mission_details'
  put '/forgot_password', to: 'users#forgot_password'
  get '/verify_email', to: 'users#verify_email'
  post '/upload_profile_pic', to: 'users#upload_profile_pic'
  get '/profile_pic', to: 'users#get_profile_pic'
  get '/accept_mesa', to: 'missions#accept_mesa_invite'
  get '/reject_mesa', to: 'missions#reject_mesa_invite'
  get '/invite_to_mesa', to: 'missions#invite_to_mesa'
devise_scope :user do
    get '/get_user'=> 'session/registrations#get_user'
    put '/update_user'=> 'session/registrations#update_user'
  end
  
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
