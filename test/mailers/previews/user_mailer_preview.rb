# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    pw = "new_pw"
    # user.activation_token = User.new_token
    # UserMailer.account_activation(user)
    UserMailer.password_reset(user, pw)
  end

end
