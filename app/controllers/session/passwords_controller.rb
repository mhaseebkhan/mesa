class Session::PasswordsController < Devise::PasswordsController
 def forgot_password
	begin
		create
	 rescue Exception => e
		 if e.class.to_s == "ActionController::UnknownFormat"
		 	respond_to do |format|
		 		format.json {render :json=> {:status => true }}
			end
	 	else
			respond_to do |format|
		 		format.json {render :json=> {:status => false }}
			end
		end
   	 end
        
 end

   def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      #sign_in(resource_name, resource)
      redirect_to request.referer , :notice => 'Your password has been changed successfully'
    else
      respond_with resource
    end
  end

end
