class Session::SessionsController < Devise::SessionsController

  prepend_before_filter :require_no_authentication, :only => [:create]
  skip_before_filter :verify_authenticity_token, :verify_signed_out_user

 def create
    resource = User.find_for_database_authentication(:email => params[:user][:email])
    return invalid_login_attempt unless resource
    respond_to do |format|
      if resource.valid_password?(params[:user][:password])
	sign_in("user", resource)
        resource.ensure_authentication_token
        format.html {after_sign_in_path_for(resource) } #dashboard_welcome_index_path, notice: 'Signed in sucessfully!' 
        format.json { render :json=> {:authentication_token=>resource.authentication_token, :email=>resource.email, :user_id=> resource.id, :status => true}}
      else
	format.html { invalid_login_attempt }
        format.json { invalid_login_attempt}
      end
    end
  end

  def destroy
    user = User.find_by_authentication_token(params[:authentication_token])
    respond_to do |format|
         if user
	    sign_out(resource_name)
            user.reset_authentication_token!
	    format.html { super }
            format.json {render :json => {:status => true}} 
         else
            format.html { super }
            format.json {render :json => { :error => 'Invalid token.', :status => false }}
          end
        
      end
  end


 def after_sign_in_path_for(resource)
     if VALID_ADMIN_USERS.include?(resource.role?) 
	redirect_to dashboard_welcome_index_path, notice: 'Signed in sucessfully!' 	
     else 
	redirect_to '/invalid_user_sign_out' 
     end
 end

  def invalid_user_sign_out
	sign_out(resource)
	redirect_to '/' , :alert => 'You are not authorized to access Mesa Admin panel'
  end

 

  protected
  
  def invalid_login_attempt
     respond_to do |format|
        format.html { redirect_to  new_user_session_path, notice: 'Invalid email or password' }
        format.json { render :json=> {:error=>"Invalid email or password", :status => false}}
     end
  end


end
