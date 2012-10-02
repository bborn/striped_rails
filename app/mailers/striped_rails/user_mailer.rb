class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def invoice(user, invoice)
    @user = UserDecorator.decorate(user)
    @invoice = InvoiceDecorator.new(invoice)
    mail(to: user.email, subject: "Brand Invoice")
  end

  def password_reset(user, token)
    @password_token = token
    mail to: user.email, subject: 'Password Reset'
  end
end
