class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:upload_profile_pic, :change_profile_pic, :get_profile_pic, :verify_email]
  authorize_resource :class => false
  # skip_authorize_resource fro API calls 
  skip_authorize_resource :only => [:upload_profile_pic, :change_profile_pic, :get_profile_pic, :verify_email]
  
  # GET /users
  # GET /users.json
  def index
     @user = User.new
     #users = Array.new
     #@users = User.all
     #@users.each do |user|
      #  user_role = user.roles.first.name.to_s unless user.roles.first.nil?
#	users <<  user.get_primary_info
 #    end

     respond_to do |format|
       format.html { render :index }
  #     format.json { render :json=> {:users => users, :status => true} }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
     # if @user.save
     #   format.html { redirect_to root_path, notice: 'User was successfully created.' }
     #  format.json { render :show, status: :created, location: @user }
     # else
     #   format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
     # end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

 

 # GET /verify_email.json
 def verify_email
	if User.email_exists? params[:email]
		render :json=> {:error => "Email already exists", :status => false}
	else
		render :json=> {:status => true}  	
	end
  end

  
  # POST /upload_profile_pic.json
  def upload_profile_pic
    user = User.exists? params[:user_id]
    if user
      user.update_attribute(:profile_pic, params[:profile_pic])
      if params[:admin_pic] == 'true'
        redirect_to root_path
      else
        render :json=> {:status => true}
      end
    else
      render :json=> {:error => "User with this id doesnot exist", :status => false}
    end
  end

  # GET /profile_pic.json
  def get_profile_pic
        user = User.exists? params[:user_id]
        if user
		render :json=> {:profile_pic => user.profile_pic.url.to_s, :status => true}  	
	else
		render :json=> {:error => "User with this id doesnot exist", :status => false}
	end
  end

  def recently_joined_users
      @recent_users = get_recently_joined_users
       render partial: '/invitations/recently_joined' , layout: false 
  end

 def user_invitation_codes
	@users_joined_by_you  = Array.new
	@code_list= current_user.invitation_codes
	current_user.taken_codes.each do |user_code| 
				if user_invitation = Invitation.find_by(invitation_code_id: user_code.id)
					 if user = User.find(user_invitation.user_id)
						@users_joined_by_you  << User.find(user_invitation.user_id).get_primary_info
					 end
				end
	end
	 render partial: '/invitations/your_codes' , layout: false 
 end

 def get_curators
	@curators  = get_network_curators
	 render partial: '/invitations/network_curators' , layout: false 
 end

  def get_curator_detail
	user = User.exists? params[:user_id]
	if user
		@user = user.get_curator_details
		respond_to do |format|
			format.html {render partial: '/users/curator_details' , layout: false }
		end
        end
 end

 def update_curator_details
	user = User.exists? params[:user_id]
	if user
		curator = user.get_curator_details
		if (curator[:no_of_codes].nil? || curator[:no_of_codes].to_i == 0) && params[:no_of_codes].to_i > 0
			params[:no_of_codes].to_i.times do user.generate_curator_code end
		end
		@user = user.update_curator_details(params[:no_of_codes],params[:code_frequency])
		respond_to do |format|
			format.html {render text: 'updated'}
		end
        end
 end

 def create_unconcious_user

   user = User.new(email: params[:user][:email] ,password: DEFAULT_PASSWORD)
   
	   if user.save
	    
		    #Forming skills
		    skills= Array.new
		    skills_names= Array.new
		    duplicate_names = Array.new
		    if  params[:skills1]
		    	skills_names << params[:skills1][:name].to_s.downcase 
			skills << params[:skills1]
		    end
		    if  params[:skills2]
		    	skills_names << params[:skills2][:name].to_s.downcase 
			skills << params[:skills2]
		    end
		    if  params[:skills3]
		    	skills_names << params[:skills3][:name].to_s.downcase 
			skills << params[:skills3]
		    end

		    duplicate_names =  skills_names.detect{ |e| skills_names.count(e) > 1 }
		    if duplicate_names.nil? || duplicate_names == ""
			    #Forming Tags
			    tags_array =Array.new
			    tags= Array.new
			    tags_array = params[:tags][:name].split(",")
			     tags_array.each do |tag|
				 tags << {:name => tag}
			      end
			   #Forming User Profile
			    #emai_name =  params[:user][:name].gsub(" ","_")
			    #user = User.create(email: "#{emai_name}#{generate_random_string}@gmail.com" ,password: DEFAULT_PASSWORD)
			    #user = User.create(email: params[:user][:email] ,password: DEFAULT_PASSWORD)
			    profile =  {:name => params[:user][:name], :phone => params[:user][:phone], :city => params[:user][:city],  :working_at => params[:user][:working_at], :passions=>  params[:user][:passions], :languages =>  params[:user][:languages] , :profile_pic =>  params[:user][:profile_pic], :skills => skills, :tags => tags, :created_by => current_user.id }
			   #Build Profile
			    user.build_profile(profile,ROLE_HARDINPUT)
			    @msg = "The user '#{params[:user][:name]}' has been successfully created."
		    else
			   @msg = "Error! Enter unique skill names"
		    end
		    
	    else
		     @msg =  "Error! This email address '#{params[:user][:email]}' has already been taken.Please enter another email."
	    end
    render partial: '/users/user_sucessful_msg' , layout: false
 end

 def get_editable_users
	user = User.exists? params[:user_id]
	@user = user.get_profile if user
	render partial: '/users/edit_user_details' , layout: false 
 end

 def edit_user_type
	user = User.exists? params[:user_id]
	if user
		prev_role = UserRole.where(user_id: params[:user_id] ).take.role_id
		@user = UserRole.where(user_id: params[:user_id] ).take.update_attribute(:role_id, params[:user_role]) 
		if  params[:user_role] == ROLE_LEADER.to_s && prev_role != ROLE_LEADER
			if  prev_role != ROLE_HARDINPUT
				password = generate_random_string
				email = user.email
				UserMailer.admin_email(user,password,email).deliver 
				user.update_attributes(password: password, is_new_admin: true)
			end
		end
	end
	render :text => 'updated'
 end

 def change_password
	User.where(id: params[:user_id]).take.update_attributes(password: params[:password], is_new_admin: false)
	render :text => 'updated'
 end

 def get_user_rating
	user = User.find(params[:user_id])
	@user = user.get_user_rating
	render partial: '/users/user_rating' , layout: false 
 end

  # POST /change_profile_pic.json
  def change_profile_pic
    user = User.exists? params[:user_id]
    user.update_attribute(:profile_pic, params[:profile_pic]) if user
    render :text => user.profile_pic_url
  end

  # POST /change_profile_pic.json
  def toggle_favorite
    user  = User.find(params[:user_id])
    user.update_attribute('favorite', (user.favorite ? false : true))
    render json: user.favorite.to_s

  end

  def delete_user
	User.find(params[:user_id]).destroy
	render :text => 'Deleted!'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :experience, :skill, :tag, :languages, :authentication_token, :profile_pic, :working_at, :passions, :city, :phone)
    end

    def get_recently_joined_users
       recently_joined_users_array = Array.new
	# ROLE_COMMONFLAGGER is required as rest of the users might not have been aded to system via invitation code
	#users = User.eager_load(:roles).where( 'roles.id in (?)', [ROLE_COMMONFLAGGER, ROLE_CURATOR,ROLE_LEADER, ROLE_ADMIN]).limit(5)
        users = User.all.limit(5)
	users.order('users.id DESC').each do |user|
		user_prof = user.get_primary_info
		user_invitation = user.invitation
 		user_prof[:invited_by] = User.find(user_invitation.invitation_code.user_id).name.to_s.titleize if user_invitation
		user_prof[:created_by]= User.find(user_prof[:created_by]).name.to_s.titleize if user_prof[:created_by]
		recently_joined_users_array << user_prof
	end
	recently_joined_users_array
  end

  def get_network_curators
	curators = Array.new
	
	users = User.eager_load(:roles).where( 'roles.id = ?', ROLE_CURATOR)
	users.each do |user|
		user_prof = user.get_primary_info
		user_prof[:open_codes] = user.open_codes.count
		curators << user_prof
	end
	curators
  end
  def unconcious_user_params
    params.require(:user).permit(:email, :password, :name, :phone, :city, :working_at , :passions, :languages, :profile_pic, {:skills=> [:name, :work_ref, :company, :time_spent]}, {:tags=> [:name]})
  end

end

