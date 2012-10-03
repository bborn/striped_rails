Gem::Specification.new do |spec|
  spec.name = "striped_rails"
  spec.version = "0.0.1"
  spec.summary = "StripedRails"
  spec.authors = ["Me"]

  spec.add_dependency 'rails', '3.2.8'
  spec.add_dependency 'bcrypt-ruby', '~> 3.0.0'

  spec.add_dependency 'unicorn', '4.2.0'

  spec.add_dependency 'friendly_id', "4.0.0"
  spec.add_dependency 'draper', '0.10.0'
  spec.add_dependency 'stripe'

  spec.add_dependency 'bootstrap-sass'

  spec.add_dependency 'simple_form', '2.0.1'

  spec.add_dependency 'dalli'
  spec.add_dependency 'redis'

  spec.add_dependency 'resque'
  spec.add_dependency 'sass-rails'  

  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rspec-rails', '2.8.1'
  spec.add_development_dependency 'factory_girl_rails', '1.6.0'
  spec.add_development_dependency 'database_cleaner', '0.7.1'
  spec.add_development_dependency 'capybara', '1.1.2'
  spec.add_development_dependency 'fakeweb', '1.3.0'
  spec.add_development_dependency 'rb-fsevent', '0.9.0'
  spec.add_development_dependency 'growl', '1.0.3'
  spec.add_development_dependency 'guard-rspec', '0.6.0'
  spec.add_development_dependency 'guard-spork', '0.5.2'
  spec.add_development_dependency 'foreman'
  spec.add_development_dependency 'letter_opener'
  spec.add_development_dependency 'heroku'

end
