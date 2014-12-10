Rails.application.routes.draw do

  devise_for(:users, :controllers => { :sessions => "users/sessions", :registrations => "users/registration"})
  root 'welcome#index'

  resources :welcome do
    collection do
      get 'dashboard'
    end
  end
  resources :user

  resources :users_admin, :controller => 'users'

end
