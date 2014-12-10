class Users::RegistrationsController < Devise::RegistrationsController
 respond_to :json
  skip_before_filter :verify_authenticity_token

  def create
    user = User.new(params[:user])
    if user.save
      render :json=> {:auth_token=>user.authentication_token, :email=>user.email}, :status=>201
      #render :json=> {:success=>true}, :status=>201
      return
    else
     # warden.custom_failure!
      render :json=> user.errors, :status=>422
    end
  end


  protected

  def invalid_login_attempt
    render :json=> {:success=>false, :message=>"Error with your login or password"}, :status=>401
  end
end
