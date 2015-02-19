class Session::RegistrationsController < Devise::RegistrationsController
   prepend_before_filter :allow_params_authentication!, :only => :create
   skip_before_filter :restrict_access_by_token, :only => :create
  def create
            build_resource(sign_up_params)
	    if resource.save
		      if resource.active_for_authentication?
			set_flash_message :notice, :signed_up if is_navigational_format?
			sign_up(resource_name, resource)
		        respond_to do |format|
                                UserMailer.welcome_email(resource).deliver
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
  end

  def update_user
	user =User.exists? (params[:user][:user_id])
	if user
		user.update_profile(params[:profile])
		respond_to do |format|
			format.json {render :json=> {:authentication_token=>user.authentication_token, :email=>user.email, :user_id=> user.id, :status => true}}
		end
        else
		respond_to do |format|
			format.json {render :json => { :error => 'Invalid id', :status => false }}
		end
        end     
  end

  def get_user
	user = User.exists? params[:user_id]
	if user
		@user = user.get_profile
		respond_to do |format|
			format.json {render :json=> {:user => @user, :status => true}}
			format.html {if params[:mesa_type] == 'open'
					render partial: '/users/user_details', :locals => { :rate => false }  , layout: false 
				     elsif params[:mesa_type] == 'closed'
					@user = user.get_mesa_rating(params[:mesa_id])
					render partial: '/users/read_only_rate_user_details', layout: false 
				     elsif params[:mesa_type] == 'underprogress'
					@user_rating = user.get_mesa_rating(params[:mesa_id])
					render partial: '/users/rate_user_details' , layout: false 
				     else 
					render partial: '/users/user_details',:locals => { :rate => true }  , layout: false 
				     end}
		end
        else
		respond_to do |format|
			format.json {render :json => { :error => 'No user found with this id', :status => false }}
		end
        end     
  end

  #private
  #def sign_up_params
  #  params.require(:user).permit(:email, :password, :password_confirmation, :remember_me, :plan_id, :is_active, :shorturl)
  #end
end
