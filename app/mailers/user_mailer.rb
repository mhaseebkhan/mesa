class UserMailer < ActionMailer::Base
  include Devise::Mailers::Helpers
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to Mesa & Cadeira')
  end

 def forgot_password_email(user)
   @user = user
    mail(to: @user.email, subject: 'Forgot Password - Mesa & Cadeira')
  end
 
 def invite_user_email(code_text,invitation_by,email)
    @code_text = code_text
    @invitation_by = invitation_by
    @email = email
    mail(to: @email, subject: 'Invitation - Mesa & Cadeira')
  end

 def validate_brief_email(owner_name)
    @owner = owner_name
     email = 'munteha18@gmail.com'#master user . email
     mail(to: email, subject: 'Breif Validation - Mesa & Cadeira')
  end

  def get_help_email(search_keys,user_name,user_email)
     @search_keys = search_keys
     @user_name = user_name
     @user_email = user_email
     email = 'munteha18@gmail.com'#admin group . email
     mail(to: email, subject: 'Help Mesa - Mesa & Cadeira')
  end

  def send_mesa_invitation_email(challenge,mesa_when,leader,users,mission_id,user_id)
     @challenge = challenge
     @when = mesa_when
     @leader =  leader
     @users = users
     @mission_id = mission_id
     @user_id = user_id
     email = 'munteha18@gmail.com'#invitee_user
     mail(to: email, subject: 'Mesa Invitation - Mesa & Cadeira')
  end

 def accept_mesa_invitation_email(user_name,mesa_title,email)
     @user_name = user_name
     @mesa_title = mesa_title
     #@email = 
     email = 'munteha18@gmail.com'#mesa owner
     mail(to: email, subject: 'Accepted Mesa Invitation - Mesa & Cadeira')
  end

  def reject_mesa_invitation_email(user_name,mesa_title,email)
     @user_name = user_name
     @mesa_title = mesa_title
     #@email = 
     email = 'munteha18@gmail.com'#mesa owner
     mail(to: email, subject: 'Rejected Mesa Invitation - Mesa & Cadeira')
  end

 def all_invitations_accepted_email(email)
     #@email = 
     email = 'munteha18@gmail.com'#mesa owner
     mail(to: email, subject: 'All Invitations Accepted - Mesa & Cadeira')
  end

  def mission_accepted_email(name,email)
     @owner = name
     #@email = 
     email = 'munteha18@gmail.com'#mesa owner
     mail(to: email, subject: 'Mission Accepted - Mesa & Cadeira')
  end
end
