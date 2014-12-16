class UserMailer < ActionMailer::Base
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

 def forgot_password_email(user)
    @user = user
    mail(to: 'munteha18@gmail.com', subject: 'Forgot Password - Mesa & Cadeira')
  end

end
