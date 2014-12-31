class MissionsController < ApplicationController
  before_action :set_mission, only: [:show, :edit, :update, :destroy]

  # GET /missions
  # GET /missions.json
  def index
    @missions = Mission.all
  end

  # GET /missions/1
  # GET /missions/1.json
  def show
  end

  # GET /missions/new
  def new
    @mission = Mission.new
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
	    	@mission.status = true
	    	@mission.is_authorized = true
		@mission.save
		format.html { redirect_to @mission, notice: 'Mission was successfully created.' }
		format.json { render :json=> {:status => true} }
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
                mission_details = mission.get_details
		mission_users = mission.get_mission_users 
		mission_leader = mission.get_mission_leader mission_users
                mission_owner = mission.get_mission_owner 
         	respond_to do |format|
		      format.json {render :json=> {:mesa_details=> mission_details, :mesa_users => mission_users, :mesa_leader => mission_leader, :mesa_owner => mission_owner, :status => true} }
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
     	if  mesa_pending_invitation.exists?
		mesa_pending_invitation.take.update_attribute(:invitation_status, ACCEPTED_MESA_INVITATION)
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
     	if  mesa_pending_invitation.exists?
		mesa_pending_invitation.take.update_attribute(:invitation_status, REJECTED_MESA_INVITATION)
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
      @mission_invitation = UserMission.create(user_id: params[:user_id], mission_id: params[:mesa_id],invitation_time: Time.now.utc, invitation_status: PENDING_MESA_INVITATION )
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

end
