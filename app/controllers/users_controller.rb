class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:upload_profile_pic, :get_profile_pic, :verify_email]
  load_and_authorize_resource 
  # skip_authorize_resource fro API calls 
  skip_authorize_resource :only => [:upload_profile_pic, :get_profile_pic, :verify_email]
  
  # GET /users
  # GET /users.json
  def index
     @unconcious_user = UnconciousUser.new
     users = Array.new
     #@users = User.all
     @users.each do |user|
        user_role = user.roles.first.name.to_s unless user.roles.first.nil?
	users <<  user.get_primary_info
     end

     respond_to do |format|
       format.html { render :index }
       format.json { render :json=> {:users => users, :status => true} }
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
		render :json=> {:status => true}  	
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
	current_user.taken_codes.collect{
				|user_code| @users_joined_by_you  << User.find(user_code.invitation.user_id).get_primary_info
				}
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
			user.generate_curator_code
		end
		@user = user.update_curator_details(params[:no_of_codes],params[:code_frequency])
		respond_to do |format|
			format.html {render text: 'updated'}
		end
        end
 end

 def create_unconcious_user
	user_params = params["unconcious_user"]
	@user_name = user_params[:name]
	user = UnconciousUser.create(name: user_params[:name],working_at: user_params[:working_at], skills: user_params[:skills],tags: user_params[:tags],passions: user_params[:passions],languages: user_params[:languages] )
        render partial: '/users/user_sucessful_msg' , layout: false 
 end

 def get_editable_users
	if params[:user_role] == ROLE_UNCONCIOUS.to_s
		user = UnconciousUser.exists? params[:user_id]
		@user = user.get_profile if user
	else
		user = User.exists? params[:user_id]
		@user = user.get_profile if user
	end
	render partial: '/users/edit_user_details' , layout: false 
 end

 def edit_user_type
	user = User.exists? params[:user_id]
	if user
		prev_role = UserRole.where(user_id: params[:user_id] ).take.role_id
		@user = UserRole.where(user_id: params[:user_id] ).take.update_attribute(:role_id, params[:user_role]) 
		if params[:user_role] == ROLE_LEADER.to_s && prev_role != ROLE_LEADER.to_s
			password = generate_random_string
			UserMailer.admin_email(user,password).deliver 
			user.update_attributes(password: password, is_new_admin: true)
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :experience, :skill, :tag, :languages, :authentication_token, :profile_pic)
    end

    def get_recently_joined_users
       recently_joined_users_array = Array.new
	# ROLE_COMMONFLAGGER is required as rest of the users might not have been aded to system via invitation code
	users = User.eager_load(:roles).where( 'roles.id in (?)', [ROLE_COMMONFLAGGER, ROLE_CURATOR, ROLE_ADMIN]).limit(1)
	users.order('users.id DESC').each do |user|
		user_prof = user.get_primary_info
		user_invitation = user.invitation
 		user_prof[:invited_by] = User.find(user_invitation.invitation_code.user_id).name
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

end

