# Resque::Server.use(Rack::Auth::Basic) do |user, password|
#   user == "admin" && password == ENV['RESQUE_PASSWORD']
# end