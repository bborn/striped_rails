# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

unless Page.count > 0
  Page.create(title: 'About', content: 'Provide information about the service here.', menu_order: 1)
  Page.create(title: 'Privacy Policy', content: 'Provide privacy information here.', menu_order: 2)
  Page.create(title: 'Terms of Service', content: 'Provide terms of service here.', menu_order: 3)
end

unless User.count > 0
  user = User.new(password: '123456', password_confirmation: '123456', email: 'admin@example.com', full_name: 'Service Admin')
  user.is_admin = true
  user.save
end
