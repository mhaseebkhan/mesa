class InvitationsController < ApplicationController
  before_action :set_invitation, only: [:show, :edit, :update, :destroy]

  # GET /invitations
  # GET /invitations.json
  def index
    @invitations = Invitation.all
  end

  # GET /invitations/1
  # GET /invitations/1.json
  def show
  end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
  end

  # GET /invitations/1/edit
  def edit
  end

  # POST /invitations
  # POST /invitations.json
  def create
    if verify_code_validity.nil?
	    user =  User.exists? invitation_params[:user_id] 
	    respond_to do |format|
	     unless  user.nil?  
				user_name = user.name
				user_role = user.roles.first.id unless user.roles.first.nil? 
	     end
	     if (user_role == ROLE_LEADER || user_role == ROLE_ADMIN)
		@invitation = Invitation.new(invitation_params)
		@invitation.invitation_sent_at = Time.now.utc
		@invitation.status = PENDING_INVITATION_STATUS
		@invitation.save
		InvitationCode.create(invitation_id: @invitation.id, code_text: params[:code])
                UserMailer.invite_user_email(params[:code],user_name,invitation_params[:invitee_email]).deliver
		format.html { redirect_to @invitation, notice: 'Invitation was successfully created.' }
		format.json { render :json=> {:status => true} }
	      else
		format.html { render :new }
		format.json { render :json=> {:error => 'This user id is not authorized to send invitation', :status => false} }
	      end
	    end
    else
	    respond_to do |format|
		format.html { render :new }
		format.json { render :json => { :error => 'Invalid or taken code.', :status => false } }
	    end
    end
  end

  # PATCH/PUT /invitations/1
  # PATCH/PUT /invitations/1.json
  def update
    respond_to do |format|
      if @invitation.update(invitation_params)
        format.html { redirect_to @invitation, notice: 'Invitation was successfully updated.' }
        format.json { render :show, status: :ok, location: @invitation }
      else
        format.html { render :edit }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitations/1
  # DELETE /invitations/1.json
  def destroy
    @invitation.destroy
    respond_to do |format|
      format.html { redirect_to invitations_url, notice: 'Invitation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /verify_code
  # GET /verify_code.json
  def verify_code
    invitaion_code = verify_code_validity
    invitation = Invitation.where(id: invitaion_code.id, status: PENDING_INVITATION_STATUS).take if invitaion_code
    invitor_name = User.find(invitation.user_id).name if invitation
    respond_to do |format|
      #format.html { redirect_to invitations_url, notice: 'Invitation was successfully destroyed.' }
      if invitor_name
      	format.json { render :json => {:invitor_name => invitor_name, :status => true } }
      else
        format.json { render :json => { :error => 'Invalid or taken code.', :status => false } }
      end
    end
  end



 
 private
    # Use callbacks to share common setup or constraints between actions.
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end

    def verify_code_validity
      InvitationCode.find_by_code_text(params[:code])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invitation_params
      params.require(:invitation).permit(:invitee_email, :invitee_name, :invitation_sent_at, :status, :user_id)
    end
end
