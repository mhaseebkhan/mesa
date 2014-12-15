class Session::RegistrationsController < Devise::RegistrationsController
   prepend_before_filter :allow_params_authentication!, :only => :create
   skip_before_filter :restrict_access_by_token, :only => :create
  def create
    unless User.find_by_email(params[:user][:email])
	    build_resource(sign_up_params)
	    if resource.save
		     UserMailer.welcome_email(resource).deliver
		     if resource.active_for_authentication?
			set_flash_message :notice, :signed_up if is_navigational_format?
			sign_up(resource_name, resource)
		        respond_to do |format|
	       		 	format.html { respond_with resource, :location => after_sign_up_path_for(resource) }
			 	format.json { resource.build_profile(params[:profile])
					      render :json=> {:authentication_token=>resource.authentication_token, :email=>resource.email, :user_id=> resource.id, :status => true}}
			end
		      else
			set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
			expire_session_data_after_sign_in!
			respond_to do |format|
				format.html {respond_with resource, :location => after_inactive_sign_up_path_for(resource)}
				 format.json { render :json => resource.errors, :status => :unprocessable_entity }
			end
		      end
	    else
	      clean_up_passwords resource
		respond_to do |format|
			format.html {respond_with resource, :location => after_inactive_sign_up_path_for(resource)}
			format.json { render :json => resource.errors, :status => :unprocessable_entity }
		end
	    end
    else
		respond_to do |format|
			format.html {redirect_to  root_path, notice: 'Email already exists'}
			 format.json { render :error => "Email already exists", :status => :false }
		end
    end
  end

  def update
	user =User.find_by_email(params[:user][:email])
	if user
		user.build_profile(params[:profile])
		respond_to do |format|
			format.json {render :json=> {:authentication_token=>user.authentication_token, :email=>user.email, :user_id=> resource.id, :status => true}}
		end
        else
		respond_to do |format|
			format.json {render :json => { :error => 'Invalid email', :status => false }}
		end
        end     
  end

  

  #private
  #def sign_up_params
  #  params.require(:user).permit(:email, :password, :password_confirmation, :remember_me, :plan_id, :is_active, :shorturl)
  #end
end
