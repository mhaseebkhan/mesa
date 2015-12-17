class UserMailer < ActionMailer::Base
  include Devise::Mailers::Helpers
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to Mesa & Cadeira')
  end

 def invite_user_email(code_text,invitation_by,email)
    @code_text = code_text
    @invitation_by = invitation_by
    @email = email
    mail(to: @email, subject: 'Invitation - Mesa & Cadeira')
  end

 def validate_brief_email(owner_name)
    @owner = owner_name
     email = SUPER_ADMIN_EMAIL.to_s
     mail(to: email, subject: 'Breif Validation - Mesa & Cadeira')
  end

  def get_help_email(help_text,search_keys,user_name,user_email,user_phone)
     @help_text = help_text
     @search_keys = search_keys
     @user_name = user_name
     @user_email = user_email
     @user_phone = user_phone
     email = SUPER_ADMIN_EMAIL.to_s
     mail(to: email, subject: 'Help Mesa - Mesa & Cadeira')
  end

  def send_mesa_invitation_email(mesa_owner,mesa_title,email)
     @mesa_owner = mesa_owner
     @mesa_title = mesa_title
     mail(to: email, subject: 'Mesa Invitation - Mesa & Cadeira')
  end

 def accept_mesa_invitation_email(user_name,mesa_title,email)
     @user_name = user_name
     @mesa_title = mesa_title
     mail(to: email, subject: 'Accepted Mesa Invitation - Mesa & Cadeira')
  end

  def reject_mesa_invitation_email(user_name,mesa_title,email)
     @user_name = user_name
     @mesa_title = mesa_title
     mail(to: email, subject: 'Rejected Mesa Invitation - Mesa & Cadeira')
  end

 def all_invitations_accepted_email(email,name)
     @name = name
     mail(to: email, subject: 'All Invitations Accepted - Mesa & Cadeira')
  end

  def mission_accepted_email(name,email)
     @owner = name
     mail(to: email, subject: 'Mission Accepted - Mesa & Cadeira')
  end

  
  def admin_email(user,code,email)
     @user = user
     @code = code
     mail(to: email, subject: 'Admin Invitation - Mesa & Cadeira')
  end

  def send_new_mesa_email(name,title)
     @owner = name.to_s.titleize
     @title = title.to_s.titleize
     mail(to: SUPER_ADMIN_EMAIL.to_s, subject: 'New Mesa Created - Mesa & Cadeira')
  end
end
