class MissionsController < ApplicationController
  before_action :set_mission, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token
  #load_and_authorize_resource 
  # GET /missions
  # GET /missions.json
  def index
   # missions = Mission.all
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
    mission_owner =  User.exists? mission_params[:owner_id] 
    respond_to do |format|
		unless  mission_owner.nil?  
			owner_role = mission_owner.roles.first.id unless mission_owner.roles.first.nil? 
		end
	      if (owner_role == ROLE_LEADER || owner_role == ROLE_ADMIN)
		@mission = Mission.new(mission_params)
		@mission.save
                @mission.set_status(MESA_IS_CREATED)
                UserMission.create(user_id: mission_params[:owner_id], mission_id: @mission.id,invitation_time: Time.now.utc, invitation_status: ACCEPTED_MESA_INVITATION)
                mission_owner = @mission.get_mission_owner 
                #UserMailer.validate_brief_email(mission_owner[:name]).deliver
		format.html { render :json=> "true" }
		format.json { render :json=> {:mesa_id => @mission.id, :status => true} }
	      else
		format.html { render :new }
		format.json { render :json=> {:error => 'This owner id is not authorized to create mesa', :status => false} }
	      end
    end
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
		missions = user.missions.references( :user_missions).select('missions.id, missions.title').where( user_missions:{ invitation_status: PENDING_MESA_INVITATION})
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
		missions = user.missions.references(:user_missions).select('missions.id, missions.title').where( user_missions:{ invitation_status: ACCEPTED_MESA_INVITATION}, missions: {status: true})
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
		get_mission_details(mission)
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
		# How to precisely check all invitations are accepteed?
		#if check_if_all_invitations_are_accepted
		 # UserMailer.all_invitations_accepted_email(mesa_owner_email).deliver
		#end
		#UserMailer.accept_mesa_invitation_email(user_name,mesa_title,mesa_owner_email).deliver
		respond_to do |format|
		      format.json {render :json=> {:status => true} }
		end
        else
	      respond_to do |format|
		      format.json {render :json=> {:error=>'No user with this mission id has pending invitation' , :status => false} }
	      end
	end
  end

  # GET /reject_mesa
  # GET /reject_mesa.json
  def reject_mesa_invite
        mesa_pending_invitation = get_mesa_pending_invitations
     	if  mesa_pending_invitation.exists? && mesa_pending_invitation.take.mesa_invitation_not_expired
		mesa_pending_invitation.take.update_attribute(:invitation_status, REJECTED_MESA_INVITATION)
		user_name = User.find(params[:user_id]).name
		mesa = Mission.find(params[:mission_id])
		mesa_title = mesa.title
		mesa_owner_email = mesa.get_mission_owner[:email]
		UserMailer.reject_mesa_invitation_email(user_name,mesa_title,mesa_owner_email).deliver
		respond_to do |format|
		      format.json {render :json=> {:status => true} }
		end
        else
	      respond_to do |format|
		      format.json {render :json=> {:error=>'No user with this mission id has pending invitation' , :status => false} }
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
     send_invite
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
   create
  end

  def show_your_open_mesa_detail
	mission = Mission.exists? params[:id]
     	if mission
		get_mission_details(mission)
		if mission.get_status == MESA_IS_AUTHORIZED
			render partial: '/missions/your_open_mesa' , layout: false 
		else
			# MESA_IS_STARTED
			render partial: '/missions/your_underprogress_mesa' , layout: false 
		end	

	end
	
  end

  def show_your_closed_mesa_detail
	get_mission
	render partial: '/missions/your_closed_mesa' , layout: false 
  end

  def show_others_open_mesa_detail
	render partial: '/missions/others_open_mesa' , layout: false 
  end

  def show_others_closed_mesa_detail
	get_mission
	render partial: '/missions/others_closed_mesa' , layout: false 
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
		mesa_chair = MesaChair.create(mission_id: params[:mesa_id], order: order)
		render :text => mesa_chair.id.to_s+"|"+ mesa_chair.order.to_s
	end
  end

  def add_to_chair
	 MesaChair.where(id: params[:chair_id]).take.update_attribute(:user_id,  params[:user_id])
	 render :text => "added to chair"
  end

  def empty_chair
	MesaChair.where(id: params[:chair_id]).take.update_attribute(:user_id, "")
	 render :text => "removed"
  end

  def remove_chair
	 MesaChair.where(id: params[:chair_id]).take.destroy
	 #pending_invitation = get_mesa_pending_invitations
	 #pending_invitation.take.destroy if pending_invitation 
	 render :text => "removed"
  end

  def get_help_from_mesa
	mesa_id = params[:mesa_id]
	owner_id = Mission.where(id: params[:mesa_id]).take.owner_id
        user_info = User.find(owner_id)
	search_keys = params[:search_keys].join(",")
	#UserMailer.get_help_email(search_keys,user_info.name,user_info.email).deliver
	render :text => search_keys
  end

  def send_mesa_invites
        mission = Mission.exists? params[:mesa_id]
	@mission_chairs = mission.get_chairs
	# global vars for email
        @challenge = mission.shared_motivation
     	@when = mission.mesa_when	
     	@leader =  User.find(mission.owner_id).name
     	@users = mission.get_mission_users
	@mission_id = params[:mesa_id]
     
	user_ids = params[:user_list]
	user_ids.collect{|user_id| params[:user_id] = user_id
						@user_id = user_id
						send_invite }
	
	render partial: '/missions/mesa_chairs' , layout: false 
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
 
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mission
      @mission = Mission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mission_params
      params.require(:mission).permit(:title, :brief, :shared_motivation, :build_intent, :from_date, :to_date, :time, :place, :status, :is_authorized, :owner_id)
    end
   
    def get_mesa_pending_invitations
	UserMission.where(user_id: params[:user_id],mission_id: params[:mission_id],invitation_status: PENDING_MESA_INVITATION)
    end

   def get_mission
	mission = Mission.exists? params[:id]
     	if mission
		get_mission_details(mission)
	end
   end

   def get_mission_details(mission)
		@mission_details = mission.get_details
		@mission_users = mission.get_mission_users 
		@mission_leader =  mission.get_mission_owner # mission.get_mission_leader @mission_users
                @mission_owner = mission.get_mission_owner 
		@mission_chairs = mission.get_chairs
                # if @mission_leader.nil? || @mission_leader == ""
		#	@mission_leader = @mission_owner
		#end
   end
	
   def send_invite
	 #UserMailer.send_mesa_invitation_email(@challenge,@when,@leader,@users,@mission_id,@user_id).deliver
	 @mission_invitation = UserMission.create(user_id: params[:user_id], mission_id: params[:mesa_id],invitation_time: Time.now.utc, invitation_status: PENDING_MESA_INVITATION )
	
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

end
