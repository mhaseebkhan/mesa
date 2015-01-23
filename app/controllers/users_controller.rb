class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  #load_and_authorize_resource
  # GET /users
  # GET /users.json
  def index
     users = Array.new
     @users = User.all
     @users.each do |user|
        user_role = user.roles.first.name.to_s unless user.roles.first.nil?
	users <<  user.get_primary_info(user.id)
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

 # GET /forgot_password.json
 def forgot_password
	user = User.email_exists? (params[:email])
	if user.present?
		#UserMailer.forgot_password_email(user).deliver
		render :json=> {:status => true}
	else
	  	render :json=> {:error => "Email doesn't exists", :status => false}
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

   #def get_user_detail
   #     user = User.exists? params[:user_id]
	# if user
		#@user = user.get_profile
	 #end
     #render partial: '/users/user_details' , layout: false 
 # end
 
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :experience, :skill, :tag, :languages, :authentication_token, :profile_pic)
    end
end

