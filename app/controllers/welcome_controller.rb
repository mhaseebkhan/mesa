class WelcomeController < ApplicationController
  before_filter :authenticate_user! , :except => [:index]

  def index
	unless user_signed_in?
		redirect_to '/users/sign_in'
	else
		 if current_user.is_new_admin 	
			redirect_to  '/welcome/dashboard' 
		 elsif current_user.role? == ROLE_COMMONFLAGGER  || current_user.role? == ROLE_CURATOR
			sign_out(current_user)
			redirect_to '/' , :alert => 'You are not authorized to access Mesa Admin panel'
                 else
			redirect_to  '/searches'
		 end
	end

  end

  def dashboard
  end

end
