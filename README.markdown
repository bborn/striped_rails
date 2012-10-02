Striped Rails Subscription Site
===============================

This project is a fully functional Rails 3.2.2 application that provides the basics to have a subscription website using Stripe as the payment processor. Just add functionality and content worth subscribing to and you are good to go! Made to work well with Heroku you can be up in no time at all.

Goals
-----

Next up is to break this out into an engine.

Technology Stack
----------------

* Rails 3.2.2 / Ruby 1.9.3p125
* Sass (with Bootstrap-Sass)
* CoffeeScript
* Haml
* Draper
* Foreman
* Unicorn
* Redis (Install Redis locally if you haven't already, designed to use a .redis directory in project root)
* Resque
* Memcache/Dalli
* Stripe

Getting Started
---------------

1. Setup a Stripe account.
2. Create any plans and coupons in Stripe.
3. Create a .env file based on the sample.env.
4. bundle install
5. Add the following fields to your User model:
  t.string :vault_token
  t.references :subscription_plan
  t.references :coupon

  add_index :striped_rails_users, :email, :unique => true
  add_index :striped_rails_users, :subscription_plan_id
  add_index :striped_rails_users, :coupon_id
  add_index :striped_rails_users, :vault_token
  add_index :striped_rails_users, :created_at

6. Make your User model (or Person, or whatever you call it, include StripedRails::User)
7. bundle exec rake db:migrate
8. bundle exec rake db:test:prepare
9. bundle exec rake db:seed
10. bundle exec foreman run bundle exec rake stripe:sync (This will sync the plans and coupons you set up on Stripe to your local db. Run whenver you change your plans/coupons on Stripe.)
11. bundle exec foreman start
12. open http://localhost:5100 to look around (Note it is 5100 instead of 5000 because Redis is first in the Procfile so Foreman skips to 5100 for the web.)

Quirks
------

1. To ensure you have your .env loaded when using the console use 'bundle exec foreman run rails console'. There is a bash script in the root called safe_console which does this for you.
2. To safely shutdown resque there is a wrapper script called start_resque that the Procfile references.
3. There is a script called sync_stripe that can be used locally to simplify the bundle exec foreman run bundle exec rake stripe:sync command.

Deploying to Heroku
-------------------

This project is designed for easy deployment to Heroku and all addon choices have a free version. Just scale up as needed.

-------------------------------------------------------------

1. bundle exec heroku create yoursite --stack cedar
2. bundle exec heroku addons:add redistogo
3. bundle exec heroku addons:add memcache
4. bundle exec heroku addons:add newrelic:standard
5. bundle exec heroku addons:add sendgrid:starter
6. bundle exec heroku addons:add piggyback_ssl

Note: This project was done on ruby 1.9.3p125. It should work fine on 1.9.2 but Rails 3.2.x is best on 1.9.3 so you may wish to follow the Heroku instructions here: http://railsapps.github.com/rails-heroku-tutorial.html

--------------------------------------------------------------------

1. heroku plugins:install https://github.com/heroku/heroku-labs.git
2. heroku labs:enable user_env_compile -a myapp
3. heroku config:add RUBY_VERSION=ruby-1.9.3-p125
4. heroku config:add PATH=bin:vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin



