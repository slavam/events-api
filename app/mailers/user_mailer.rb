class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user, pw)
    @user = user
    @new_pw = pw
    mail to: user.email, subject: "Password reset"
  end
end
