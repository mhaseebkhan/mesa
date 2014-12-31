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

end
