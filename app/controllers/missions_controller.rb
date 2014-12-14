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
    @mission = Mission.new(mission_params)

    respond_to do |format|
      if @mission.save
        format.html { redirect_to @mission, notice: 'Mission was successfully created.' }
        format.json { render :show, status: :created, location: @mission }
      else
        format.html { render :new }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
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
        user = User.find_by_id(params[:user_id])
	if user
		missions = user.missions.references( :user_missions).where( user_missions:{ invitation_status: 'pending'})
		respond_to do |format|
		      #format.html { redirect_to missions_url, notice: 'Mission was successfully destroyed.' }
		      format.json {render :json=> {:mesa_invites=> missions, :status => true} }
		end
        else
	      respond_to do |format|
		      #format.html { redirect_to missions_url, notice: 'Mission was successfully destroyed.' }
		      format.json {render :json=> {:error=>'No user exists with id' , :status => false} }
	      end
	end
  end

  # GET /get_working_missions
  # GET /get_working_missions.json
  def get_working_missions
   	#get all missions of user with invitaion_status = pending
        user = User.find_by_id(params[:user_id])
	if user
		missions = user.missions.references(:user_missions).where( user_missions:{ invitation_status: 'accepted'})
		respond_to do |format|
		      #format.html { redirect_to missions_url, notice: 'Mission was successfully destroyed.' }
		      format.json {render :json=> {:working_mesa=> missions, :status => true} }
		end
        else
	      respond_to do |format|
		      #format.html { redirect_to missions_url, notice: 'Mission was successfully destroyed.' }
		      format.json {render :json=> {:error=>'No user exists with id' , :status => false} }
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
      params.require(:mission).permit(:title, :brief, :shared_motivation, :build_intent, :from_date, :to_date, :time, :place, :status, :is_authorized)
    end
end
