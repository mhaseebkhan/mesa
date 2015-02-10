class WelcomeController < ApplicationController
  before_filter :authenticate_user! , :except => [:index]

  def index
	unless user_signed_in?
		redirect_to '/users/sign_in'
	end
  end

  def dashboard
  end

end
