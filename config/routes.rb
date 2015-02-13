Rails.application.routes.draw do

  get '/verify_code', to: 'invitations#verify_code'
  get '/get_mission_invites', to: 'missions#get_mission_invites'
  get '/get_working_missions', to: 'missions#get_working_missions'
  get '/get_mission_details', to: 'missions#get_mission_details'
 
  get '/verify_email', to: 'users#verify_email'
  post '/upload_profile_pic', to: 'users#upload_profile_pic'
  post '/change_profile_pic', to: 'users#change_profile_pic'
  get '/profile_pic', to: 'users#get_profile_pic'
  get '/accept_mesa', to: 'missions#accept_mesa_invite'
  get '/reject_mesa', to: 'missions#reject_mesa_invite'
  get '/invite_to_mesa', to: 'missions#invite_to_mesa'
 
#  get '/search_keys_for_chair', to: 'searches#search_keys_for_chair'
  devise_scope :user do
    get '/get_user'=> 'session/registrations#get_user',:defaults => { :format => 'html' }
    put '/update_user'=> 'session/registrations#update_user',:defaults => { :format => 'html' }
    post '/forgot_password', to: 'session/passwords#forgot_password',:defaults => { :format => 'json' }
    get '/invalid_user_sign_out', :to => 'session/sessions#invalid_user_sign_out'
  end
  
  resources :invitations do
    collection do
	 get 'generate_code'
	 get 'save_code'
    end
  end

  resources :missions do
   collection do
      get 'create_mission'
      get 'send_brief_validation'
      get 'show_open_mesa_detail'
      get 'show_closed_mesa_detail'
      get 'show_pending_mesa_detail'    
      get 'create_new_chair' 
      get 'add_to_chair'  
      get 'empty_chair'  
      get 'edit_chair'     
      get 'get_help_from_mesa'  
      get 'send_mesa_invites' 
      get 'rate_user_detail'  	
      get 'authorize_mesa'  
      get 'get_mission_chairs'
      get 'start_mesa'
      get 'close_mesa'  
      get 'rate_users'  
    end
  end
  resources :searches do
   collection do
      get 'search_keys'
      get 'search_keys_for_chair'
      get 'search_by_name'
      get 'filter_users'
    end
  end


  devise_for(:users, :controllers => { :sessions => "session/sessions", :registrations => "session/registrations",:passwords => "session/passwords"})
  # devise_for(:passwords, :controllers => { :passwords => "session/passwords"})
  root 'welcome#index'

  resources :welcome do
    collection do
      get 'dashboard'
    end
  end
  resources :users do
    collection do
      get 'recently_joined_users'
      get 'user_invitation_codes'
      get 'get_curators'
      get 'get_curator_detail'
      get 'update_curator_details'
      post 'create_unconcious_user'
      get 'get_unconcious_user'
      get 'get_editable_users'
      get 'edit_user_type'
      get 'change_password'
      get 'get_user_rating'
    end
  end
  resources :users_admin, :controller => 'users'

end
