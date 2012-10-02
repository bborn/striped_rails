require "striped_rails" # Require all the real code
require "rails"

require "friendly_id"
require "draper"
require "stripe"
require "bootstrap-sass"
require "simple_form"
require "dalli"
require "redis"
require "resque"

module StripedRails
  class Engine < ::Rails::Engine

    isolate_namespace StripedRails
    engine_name 'striped_rails'

    config.layout = "striped_rails/base"
    config.user_class = "::User"

    # initializer "static assets" do |app|
      # app.middleware.use ActionDispatch::Static, "#{root}/public" # Old way, does not work in production
      # app.middleware.insert_after ActionDispatch::Static, ActionDispatch::Static, "#{root}/public"
    # end

    def self.user
      config.user_class.constantize
    end

  end
end
