require 'spec_helper'

describe "Users" do
  describe "GET /users/subscribe" do
    it "should create a user when filled correctly" do
      FakeWeb.register_uri(:post, "https://api.stripe.com/v1/tokens", {body: '{"used": false, "livemode": false, "card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "object": "card", "cvc_check": "pass", "last4": "4242", "country": "US"}, "currency": "usd", "object": "token", "created": 1330303761, "id": "tok_pno1sAjjtmoHZp"}', status: ["200", "OK"]})
      FakeWeb.register_uri(:post, "https://api.stripe.com/v1/customers", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
      @subscription_plan = Factory(:subscription_plan)
      visit new_user_path
      fill_in('Username', with: 'user1')
      fill_in('Email', with: 'user1@test.com')
      fill_in('Your name or company name', with: 'User One')
      fill_in('Password', with: '123456')
      fill_in('Password confirmation', with: '123456')
      fill_in('Credit Card Number', with: '4242424242424242')
      fill_in('Security Code on Card (CVV)', with: '123')
      select('February', from: 'card_month')
      select('2013', from: 'card_year')
      click_on('Sign Up')
      User.exists?('user1').should be_true
    end

  end
end
