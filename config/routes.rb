Rails.application.routes.draw do

  get '/verify_code', to: 'invitations#verify_code'
  get '/get_mission_invites', to: 'missions#get_mission_invites'
  get '/get_working_missions', to: 'missions#get_working_missions'
  get '/get_mission_details', to: 'missions#get_mission_details'
  get '/forgot_password', to: 'users#forgot_password'
  get '/verify_email', to: 'users#verify_email'
  post '/upload_profile_pic', to: 'users#upload_profile_pic'
  get '/profile_pic', to: 'users#get_profile_pic'
  get '/accept_mesa', to: 'missions#accept_mesa_invite'
  get '/reject_mesa', to: 'missions#reject_mesa_invite'
  get '/invite_to_mesa', to: 'missions#invite_to_mesa'
#  get '/search_keys_for_chair', to: 'searches#search_keys_for_chair'
  devise_scope :user do
    get '/get_user'=> 'session/registrations#get_user',:defaults => { :format => 'html' }
    put '/update_user'=> 'session/registrations#update_user',:defaults => { :format => 'html' }
  end
  
  resources :invitations
  resources :missions do
   collection do
      get 'create_mission'
      post 'send_brief_validation'
      get 'show_your_open_mesa_detail'
      get 'show_others_open_mesa_detail'
      get 'show_your_closed_mesa_detail'
      get 'show_others_closed_mesa_detail'
      get 'show_pending_mesa_detail'    
      post 'create_new_chair' 
      post 'add_to_chair'  
      post 'empty_chair'  
      post 'remove_chair'     
      get 'get_help_from_mesa'  
      post 'send_mesa_invites' 
      post 'rate_user_detail'  	
      get 'authorize_mesa'  

    end
  end
  resources :searches do
   collection do
      get 'search_keys'
      get 'search_keys_for_chair'
    end
  end

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
