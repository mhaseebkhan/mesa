class MissionsController < ApplicationController
  require 'parse-ruby-client'
  before_action :set_mission, only: [:show, :edit, :update, :destroy]
  #skip_before_filter :verify_authenticity_token
   before_filter :authenticate_user!, :except => [:get_mission_details, :get_mission_invites, :get_working_missions, :accept_mesa_invite, :reject_mesa_invite, :send_notification]
  load_and_authorize_resource 
  # skip_authorize_resource fro API calls 
  skip_authorize_resource :only => [:get_mission_details, :get_mission_invites, :get_working_missions, :accept_mesa_invite, :reject_mesa_invite, :send_notification]
  # GET /missions
  # GET /missions.json
  def index
   # @missions = Mission.all.order("id ASC")
    @my_open_missions = @missions.find_all{|mission| mission.owner_id == current_user.id && mission.is_authorized == true}
    @my_closed_missions = @missions.find_all{|mission| mission.owner_id ==  current_user.id && mission.get_status == MESA_IS_COMPLETED }
    @others_open_missions = @missions.find_all{|mission| mission.owner_id !=  current_user.id  && mission.is_authorized == true}
    @others_closed_missions = @missions.find_all{|mission| mission.owner_id !=  current_user.id && mission.get_status == MESA_IS_COMPLETED}
    @pending_missions = @missions.find_all{|mission| mission.get_status == MESA_IS_CREATED}
  end

  # GET /missions/1
  # GET /missions/1.json
  def show
  end

  # GET /missions/new
  def new
   # @mission = Mission.new
  end

  # GET /missions/1/edit
  def edit
  end

  # POST /missions
  # POST /missions.json
  def create
   # mission_owner =  User.exists? mission_params[:owner_id] 
   # respond_to do |format|
		#unless  mission_owner.nil?  
		#	owner_role = mission_owner.roles.first.id unless mission_owner.roles.first.nil? 
		#end
	   #   if VALID_ADMIN_USERS.include?(owner_role)
		@mission = Mission.new(mission_params)
		@mission.save
                @mission.set_status(MESA_IS_AUTHORIZED)
                #UserMission.create(user_id: current_user.id, mission_id: @mission.id,invitation_time: Time.now.utc, invitation_status: ACCEPTED_MESA_INVITATION)
                mission_owner = @mission.get_mission_owner 
		UserMailer.send_new_mesa_email(mission_owner[:name],@mission.title).deliver
                #UserMailer.validate_brief_email(mission_owner[:name]).deliver
		#format.json { render :json=> {:mesa_id => @mission.id, :status => true} }
	   #   else
		#format.json { render :json=> {:error => 'You do not have permission to create mesa', :status => false} }
	  #    end
   # end
  end

  # PATCH/PUT /missions/1
  # PATCH/PUT /missions/1.json
  def update
    respond_to do |format|
      if @mission.update(mission_params)
        format.html { redirect_to @mission, notice: 'Mission was successfully updated.' }
        format.json { render :show, status: :ok, location: @mission }
      else
        format.html { render :edit }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /missions/1
  # DELETE /missions/1.json
  def destroy
    @mission.destroy
    respond_to do |format|
      format.html { redirect_to missions_url, notice: 'Mission was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /get_mission_invites
  # GET /get_mission_invites.json
  def get_mission_invites
	#get all missions of user with invitaion_status = pending
        user = User.exists? (params[:user_id])
	if user
		missions = user.missions.references( :user_missions).select('missions.id, missions.title, user_missions.invitation_time').where( user_missions:{ invitation_status: PENDING_MESA_INVITATION})
		respond_to do |format|
		      format.json {render :json=> {:mesa_invites=> missions, :status => true} }
		end
        else
	      respond_to do |format|
		      format.json {render :json=> {:error=>'No user exists with id' , :status => false} }
	      end
	end
  end

  # GET /get_working_missions
  # GET /get_working_missions.json 
  def get_working_missions
   	#get all missions of user with invitaion_status = pending and mission status = true
        user = User.exists?(params[:user_id])
	if user
		missions = user.missions.references(:user_missions).select('missions.id, missions.title').where( user_missions:{ invitation_status: ACCEPTED_MESA_INVITATION}, missions: {is_authorized: true})
		respond_to do |format|
		      format.json {render :json=> {:working_mesa=> missions, :status => true} }
		end
        else
	      respond_to do |format|
		      format.json {render :json=> {:error=>'No user exists with id' , :status => false} }
	      end
	end
  end

  # GET /get_mission_details
  # GET /get_mission_details.json   
  def get_mission_details
   	mission = Mission.exists? params[:mission_id]
     	if mission
		mission_details(mission)
                respond_to do |format|
		      format.json {render :json=> {:mesa_details=> @mission_details, :mesa_users => @mission_users, :mesa_leader => @mission_leader, :mesa_owner => @mission_owner, :status => true} }
		end
        else
	      respond_to do |format|
		      format.json {render :json=> {:error=>'No mesa exists with id' , :status => false}}
	      end
	end
  end

  # GET /accept_mesa
  # GET /accept_mesa.json
  def accept_mesa_invite
        mesa_pending_invitation = get_mesa_pending_invitations 
     	if  mesa_pending_invitation.exists? && mesa_pending_invitation.take.mesa_invitation_not_expired
		mesa_pending_invitation.take.update_attribute(:invitation_status, ACCEPTED_MESA_INVITATION)
		user_name = User.find(params[:user_id]).name
		mesa = Mission.find(params[:mission_id])
		mesa_title = mesa.title
		mesa_owner_email = mesa.get_mission_owner[:email]
                mesa_owner_name = mesa.get_mission_owner[:name]
		# How to precisely check all invitations are accepteed?
		#if check_if_all_invitations_are_accepted
		 # UserMailer.all_invitations_accepted_email(mesa_owner_email,mesa_owner_name ).deliver
		#end
		UserMailer.accept_mesa_invitation_email(user_name,mesa_title,mesa_owner_email).deliver
		@message = 'Your Mesa Acceptance notification has been sent.'
		respond_to do |format|
		      format.json {render :json=> {:status => true} }
		      format.html {render partial: 'layouts/mesa_modal_box.html.erb', layout: false}
		end
        else
	      respond_to do |format|
					@message = 'Invitation expired or No user with this mission id has pending invitation'
			 format.html {render partial: 'layouts/mesa_modal_box.html.erb', layout: false}
		      format.json {render :json=> {:error=> @message , :status => false} }
	      end
	end
  end

  # GET /reject_mesa
  # GET /reject_mesa.json
  def reject_mesa_invite
        mesa_pending_invitation = get_mesa_pending_invitations
     	if  mesa_pending_invitation.exists? && mesa_pending_invitation.take.mesa_invitation_not_expired
		mesa_pending_invitation.take.update_attribute(:invitation_status, REJECTED_MESA_INVITATION)
		mesa_pending_invitation.take.allocate_time_slot_to_next_user	
		user_name = User.find(params[:user_id]).name
		mesa = Mission.find(params[:mission_id])
		mesa_title = mesa.title
		mesa_owner_email = mesa.get_mission_owner[:email]
		UserMailer.reject_mesa_invitation_email(user_name,mesa_title,mesa_owner_email).deliver
		@message = 'Your Mesa Rejection notification has been sent.'
		respond_to do |format|
		      format.json {render :json=> {:status => true} }
		      format.html {render partial: 'layouts/mesa_modal_box.html.erb', layout: false }
		end
			else
				@message = 'Invitation expired or No user with this mission id has pending invitation'
	      respond_to do |format|
		       format.html {render partial: 'layouts/mesa_modal_box.html.erb', layout: false}
		      format.json {render :json=> {:error=> @message , :status => false} }
	      end
	end
  end

  # GET /invite_to_mesa
  # GET /invite_to_mesa.json
  # To validate:
	# Only Admin/leader can send invitations
	# mesa invitation will be expired after its time
  def invite_to_mesa
    unless UserMission.exists?(params[:user_id],params[:mesa_id]).nil?
     user=User.find(params[:user_id])
     send_invite(user)
    end
    respond_to do |format|
      if  @mission_invitation
        format.html { redirect_to @mission, notice: 'Mission was successfully created.' }
        format.json { render :json=> {:status => true} }
      else
        format.html { render :new }
        format.json { render :json=> {:error => 'Invalid user id,mesa id or duplicate invitation', :status => false} }
      end
    end
  end

  def send_brief_validation
   params[:mission] = params
   params[:owner_id] = current_user.id
   if can_create_new_mesa(params[:owner_id])
   	create
	render :text => "Great.<br> You can manage your mesa in Admin Mesa section.</p>" 
	#"<p>Great.<br> Now we need to validate your brief.We'll reply as soon as possible</p>"
   else
     	 render :text => "Your Mesa cannot be created.You have reached maximum limit of 3 mesas per year"
   end

  end

  def show_open_mesa_detail
	mission = Mission.exists? params[:id]
     	if mission
		mission_details(mission)
		if mission.get_status == MESA_IS_AUTHORIZED
			render partial: '/missions/open_mesa' , layout: false 
		else
			# MESA_IS_STARTED
			render partial: '/missions/underprogress_mesa' , layout: false 
		end	

	end
	
  end

  def show_closed_mesa_detail
	get_mission
	render partial: '/missions/closed_mesa' , layout: false 
  end

  def show_pending_mesa_detail
	get_mission
	render partial: '/missions/pending_mesa' , layout: false 
  end

  def create_new_chair
	existing_mesa_chairs = MesaChair.where(mission_id: params[:mesa_id])
	chair_count = existing_mesa_chairs.count
	if chair_count == 12
		render :text => "count completed"
	else
		recent_chair = existing_mesa_chairs.order('id DESC').take
		order = recent_chair ? recent_chair.order + 1 : 1 
		mesa_chair = MesaChair.create(mission_id: params[:mesa_id], order: order, title: "Chair #{order}")
		render :text => mesa_chair.id.to_s+"|"+ mesa_chair.order.to_s
	end
  end

  def add_to_chair
	 chair = MesaChair.where(id: params[:chair_id]).take
	 if chair
		MesaChairUser.create(mesa_chair_id: chair.id, user_id: params[:user_id])
	 end
	 render :text => "added to chair"
  end

  def empty_chair
	 chair = MesaChair.where(id: params[:chair_id]).take
	 if chair
		MesaChairUser.find_by(mesa_chair_id: chair.id, user_id: params[:user_id]).destroy
	 end
	 render :text => "removed"
  end

  def edit_chair
	 mesa_chair = MesaChair.where(id: params[:chair_id]).take
	if params[:chair_title] == ""
	 params[:chair_title] = "Chair #{mesa_chair.order}" 
	end
	 mesa_chair.update_attribute(:title, params[:chair_title])
	 mission = Mission.exists? mesa_chair.mission_id
	 @mission_chairs = mission.get_chairs
	 render partial: '/missions/mesa_chairs' , layout: false 
  end

  def get_help_from_mesa
	mesa_id = params[:mesa_id]
	owner_id = Mission.where(id: params[:mesa_id]).take.owner_id
        user_info = User.find(owner_id)
	if params[:search_keys] || params[:help_text]
		search_keys = params[:search_keys].join(",") 
		UserMailer.get_help_email( params[:help_text],search_keys,user_info.name,user_info.email,user_info.phone).deliver
		render :text => search_keys
	else 
		render :text => "empty string"
	end

  end

  def send_mesa_invites
	
	mission = Mission.exists? params[:mesa_id]
	@mission_id = params[:mesa_id]
        @mission_title = mission.title
	@mesa_owner = mission.get_mission_owner 
       if params[:user_list]
		mission.set_all_invites_out
		# global vars for email
		users_info = params[:user_list]
		chair_array = Array.new
		users_info.each do |user|
			chair_id = user.split("_")[0]
			user_id = user.split("_")[1]
			params[:user_id] = user_id
			@user_id = user_id
                        user = User.find(user_id)
			@email = user.email
                       	if chair_array.include?(chair_id)
				UserMission.create(user_id:  user_id, mission_id: params[:mesa_id],invitation_time: Time.now.utc, invitation_status: WAITING_MESA_INVITATION )
			else
			 	send_invite (user)
			end
                        chair_array << chair_id
		end
		
	end
	mission_details(mission)
	render partial: '/missions/open_mesa' , layout: false 
  end

  def rate_user_detail
        user = User.exists? params[:user_id]
	 if user
	      user.rate_profile params
	 end
     render :text => "updated"
  end

  def authorize_mesa
     mission = Mission.exists? params[:mesa_id]
     mission.set_status(MESA_IS_AUTHORIZED)
     leader = mission.get_mission_owner 
     UserMailer.mission_accepted_email(leader[:name],leader[:email]).deliver
     redirect_to missions_path, :notice => ("Mesa has been authorized") 
  end

  def get_mission_chairs
	mission = Mission.exists? params[:mesa_id]
	@mission_chairs = mission.get_chairs
	user = User.exists? params[:user_id]
	@chair_user = user.get_primary_info
	render partial: '/missions/chair_list' , layout: false 
  end

  def start_mesa
	mission = Mission.exists? params[:mesa_id]
     	mission.set_status(MESA_IS_STARTED)
	mission_details(mission)
	render partial: '/missions/underprogress_mesa' , layout: false 
  end
 
   def close_mesa
	mission = Mission.exists? params[:mesa_id]
     	mission.set_status(MESA_IS_COMPLETED)
	mission_details(mission)
        index
	render partial: '/missions/index' , layout: false 
  end

  def rate_users
	mission = Mission.exists? params[:mesa_id]
     	#mission.set_status(MESA_IS_COMPLETED)
	mission_details(mission)
	render partial: '/missions/rate_users' , layout: false 
  end

  def send_notification
	data = { :alert => "You have received a Mesa Invitation", :userId => params[:user_id], :mesaId => params[:mesa_id], :sound => "cheering.caf"}
	push = Parse::Push.new(data)
	query = Parse::Query.new(Parse::Protocol::CLASS_INSTALLATION).eq('userId', params[:user_id].to_i)
	push.where = query.where
       respond_to do |format|
	      if push.save
		    format.json { render :json=> {:status => true} }
	      else
		   format.json { render :json=> {:status => false} }
	      end
    	end
  end
 
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mission
      @mission = Mission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mission_params

      params.require(:mission).permit(:title, :brief, :shared_motivation, :build_intent, :from_date, :to_date, :to_time,:from_time, :place, :status, :is_authorized, :owner_id)
    end
   
    def get_mesa_pending_invitations
	UserMission.where(user_id: params[:user_id],mission_id: params[:mission_id],invitation_status: PENDING_MESA_INVITATION)
    end

   def get_mission
	mission = Mission.exists? params[:id]
     	if mission
		mission_details(mission)
	end
   end

   def mission_details(mission)
		@mission_details = mission.get_details
		@mission_users = mission.get_mission_users 
		@mission_leader =  mission.get_mission_owner # mission.get_mission_leader @mission_users
                @mission_owner = mission.get_mission_owner 
		@mission_chairs = mission.get_chairs
		@mission_send_invite = mission.send_invites
                # if @mission_leader.nil? || @mission_leader == ""
		#	@mission_leader = @mission_owner
		#end
   end
	
   def send_invite(user) 
	if user.role? == ROLE_HARDINPUT
		@mission_invitation = UserMission.create(user_id: params[:user_id], mission_id: params[:mesa_id],invitation_time: Time.now.utc, invitation_status: ACCEPTED_MESA_INVITATION )
	else
		UserMailer.send_mesa_invitation_email(@mesa_owner[:name],@mission_title,@email).deliver 
		send_push_notification
		@mission_invitation = UserMission.create(user_id: params[:user_id], mission_id: params[:mesa_id],invitation_time: Time.now.utc, invitation_status: PENDING_MESA_INVITATION )
	end
	
	
   end

   def check_if_all_invitations_are_accepted
	mission_invites_status = UserMission.where(mission_id: params[:mission_id]).pluck(:invitation_status)
	if (mission_invites_status.include?(PENDING_MESA_INVITATION) || mission_invites_status.include?(EXPIRED_MESA_INVITATION) || mission_invites_status.include?(REJECTED_MESA_INVITATION) ) 
		false
	else
		MesaChair.where(mission_id: params[:mission_id]).destroy
		mission = Mission.find(params[:mission_id])
		mission.set_status(MESA_IS_STARTED)
		true
	end
	
	
   end

  def can_create_new_mesa(user_id)
	mesa_creation_dates = Mission.where(owner_id: user_id).pluck(:created_at)
	mission_created_this_year = mesa_creation_dates.find_all{|creation_date| creation_date.to_date.year == Time.now.utc.year}.length
	mission_created_this_year <= 2 ? true : false
   end

  def send_push_notification
	data = { :alert => "You have received a Mesa Invitation", :userId => @user_id, :mesaId => @mission_id, :sound => "cheering.caf"}
	push = Parse::Push.new(data)
	query = Parse::Query.new(Parse::Protocol::CLASS_INSTALLATION).eq('userId', @user_id.to_i)
	push.where = query.where
	push.save
  end

end
