Gem::Specification.new do |spec|
  spec.name = "striped_rails"
  spec.version = "0.0.1"
  spec.summary = "StripedRails"
  spec.authors = ["Me"]

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

end
