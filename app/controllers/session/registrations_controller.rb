class Session::RegistrationsController < Devise::RegistrationsController
   prepend_before_filter :allow_params_authentication!, :only => :create
   skip_before_filter :restrict_access_by_token, :only => :create
  def create
    build_resource(sign_up_params)
    if resource.save
         resource.build_profile(params[:profile])
       	      if resource.active_for_authentication?
		set_flash_message :notice, :signed_up if is_navigational_format?
		sign_up(resource_name, resource)
                respond_to do |format|
       		 	format.html { respond_with resource, :location => after_sign_up_path_for(resource) }
		 	format.json { render :json=> {:authentication_token=>resource.authentication_token, :email=>resource.email, :status => true}}
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
  end

  #private
  #def sign_up_params
  #  params.require(:user).permit(:email, :password, :password_confirmation, :remember_me, :plan_id, :is_active, :shorturl)
  #end
end
