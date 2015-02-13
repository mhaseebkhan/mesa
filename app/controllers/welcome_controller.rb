class WelcomeController < ApplicationController
  before_filter :authenticate_user! , :except => [:index]

  def index
	unless user_signed_in?
		redirect_to '/users/sign_in'
	else
		 if current_user.is_new_admin 	
			redirect_to  '/welcome/dashboard' 
		 else
			redirect_to  '/searches'
		 end
	end

  end

  def dashboard
  end

end
