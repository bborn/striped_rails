require 'spec_helper'


module StripedRails
  describe User do
    context "when validating attributes" do
      before :each do
        @user = Factory.build(:user)
      end

      it "should be valid with default factory values" do
        @user.should be_valid
      end

      it "should be invalid without a username" do
        @user.username = nil
        @user.should be_invalid
      end

      it "should be invalid without a password when creating" do
        @user.password = nil
        @user.should be_invalid
      end

      it "should be invalid without a confirmation password" do
        @user.password_confirmation = nil
        @user.should be_invalid
      end

      it "should be invalid without a matching confirmation password" do
        @user.password = '1234'
        @user.password_confirmation = '2345'
        @user.should be_invalid
      end

      it "should be invalid without an email address" do
        @user.email = nil
        @user.should be_invalid
      end

      it "should be invalid without a full name" do
        @user.full_name = nil
        @user.should be_invalid
      end

      it "should be invalid with a username longer than 50 characters" do
        @user.username = 'x'*51
        @user.should be_invalid
      end

      it "should be invalid with a username containing non alpha-numerics, '-' is ok" do
        @user.username = 'x -3'
        @user.should be_invalid
      end

      it "should be invalid with a duplicate username" do
        @user1 = Factory(:user, username: 'user1')
        @user2 = Factory.build(:user, username: 'user1')
        @user2.should be_invalid
      end

      it "should be invalid with an email longer than 255 characters" do
        @user.email = 'x'*256
        @user.should be_invalid
      end

      it "should be invalid with an email without a basic format" do
        @user.email = 'xxx'
        @user.should be_invalid
      end

      it "should be invalid with a duplicate email" do
        @user1 = Factory(:user, email: 'user1@test.com')
        @user2 = Factory.build(:user, email: 'user1@test.com')
        @user2.should be_invalid
      end

      it "should be invalid with a full name longer than 255 characters" do
        @user.full_name = 'x'*256
        @user.should be_invalid
      end
    end

    context "when mass assigning attributes" do
      before :each do
        @assignable = {username: 'x', password: 'x', password_confirmation: 'x', email: 'x@x.com', full_name: 'x', subscription_plan_id: 1, card_token: 'x'}
        @user = Factory(:user)
      end

      it "should allow assignable attributes to be mass assigned" do
        lambda{@user.attributes = @attributes}.should_not raise_error
      end

      it "should not allow is_admin to be mass assigned" do
        lambda{@user.attributes = {is_admin: true}}.should raise_error
      end
    end

    context "#sanitize" do
      before :each do
        @user = Factory.build(:user)
      end

      it "should have a method to downcase and strip whitespace" do
        User.sanitize(" TEST ").should == "test"
      end

      it "should handle nil case" do
        User.sanitize(nil).should == nil
      end

      it "should sanitize username" do
        @user.username = " TEST "
        @user.username.should == "test"
      end

      it "should sanitize email" do
        @user.email = " TEST@TEST.COM "
        @user.email.should == "test@test.com"
      end
    end

    context "retrieval tokens" do
      before :each do
        @user = Factory(:user)
      end

      it "should have a remember_me_token" do
        @user.remember_me_token.should be_present
      end

      it "should have a consistant remember_me_token" do
        token = @user.remember_me_token
        User.find_by_remember_me_token(token).should == @user
      end

      it "should have a forgot_password_token" do
        @user.forgot_password_token.should be_present
      end

      it "should find a user by forgot_password_token" do
        token = @user.forgot_password_token
        User.find_by_forgot_password_token(token).should == @user
      end

      it "should expire forgot_password_token after expire given" do
        token = @user.forgot_password_token(1)
        sleep(2)
        User.find_by_forgot_password_token(token).should == nil
      end
    end

    context "stripe interaction" do
      before :each do
        @subscription_plan = Factory(:subscription_plan)
        @user = Factory.build(:user)
        @user.subscription_plan = @subscription_plan
        @user.card_token = 'xxxxxx'
      end

      it "should fail to create with an invalid user" do
        @user.username = nil
        @user.create_with_stripe.should be_false
      end

      it "should fail to create with an invalid card token" do
        FakeWeb.register_uri(:post, "https://api.stripe.com/v1/customers", {body: '{"error": {"type": "invalid_request_error", "message": "You must supply a valid card"}}', status: ["400", "Request Failed"]})
        @user.create_with_stripe.should be_false
        @user.errors.full_messages.should include("There was a problem with your credit card.")
      end

      it "should create the user with a stripe customer" do
        FakeWeb.register_uri(:post, "https://api.stripe.com/v1/customers", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        @user.create_with_stripe.should be_true
      end

      it "should fail to update card with an invalid user" do
        @user.username = nil
        @user.update_credit_card.should be_false
      end

      it "should fail to update card with an invalid card token" do
        FakeWeb.register_uri(:get, "https://api.stripe.com/v1/customers/123456", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        FakeWeb.register_uri(:post, "https://api.stripe.com/v1/customers/123456", {body: '{"error": {"type": "invalid_request_error", "message": "You must supply a valid card"}}', status: ["400", "Request Failed"]})
        @user.vault_token = '123456'
        @user.update_credit_card.should be_false
        @user.errors.full_messages.should include("There was a problem with your credit card.")
      end

      it "should update the stripe customer with a new card" do
        FakeWeb.register_uri(:get, "https://api.stripe.com/v1/customers/123456", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        FakeWeb.register_uri(:post, "https://api.stripe.com/v1/customers/123456", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        @user.vault_token = '123456'
        @user.update_credit_card.should be_true
      end

      it "should update stripe if email changes" do
        FakeWeb.register_uri(:get, "https://api.stripe.com/v1/customers/123456", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        FakeWeb.register_uri(:post, "https://api.stripe.com/v1/customers/123456", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        @user.vault_token = '123456'
        @user.email = 'new-email@test.com'
        @user.save.should be_true
      end

      it "should get the last4 credit card digits from Stripe" do
        FakeWeb.register_uri(:get, "https://api.stripe.com/v1/customers/123456", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        @user.vault_token = '123456'
        @user.last4.should == '4242'
      end

      it "should switch subscription plans with Stripe" do
        FakeWeb.register_uri(:get, "https://api.stripe.com/v1/customers/123456", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        FakeWeb.register_uri(:post, "https://api.stripe.com/v1/customers/123456/subscription", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        subscription_plan1 = Factory(:subscription_plan, vault_token: 'plan-1')
        subscription_plan2 = Factory(:subscription_plan, vault_token: 'plan-2')
        user = Factory(:user, vault_token: '123456', subscription_plan: subscription_plan1)
        user.switch_subscription_plan(subscription_plan2)
        user.subscription_plan.should == subscription_plan2
      end

      it "should cancel subscription plans with Stripe" do
        FakeWeb.register_uri(:get, "https://api.stripe.com/v1/customers/123456", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        FakeWeb.register_uri(:delete, "https://api.stripe.com/v1/customers/123456/subscription", {body: '{"livemode": false, "active_card": {"type": "Visa", "exp_month": 2, "exp_year": 2013, "last4": "4242", "object": "card", "country": "US"}, "object": "customer", "description": "Customer for alex.peachey@tekukan.com", "created": 1330107519, "id": "123456"}', status: ["200", "OK"]})
        subscription_plan = Factory(:subscription_plan, vault_token: 'plan-1')
        user = Factory(:user, vault_token: '123456', subscription_plan: subscription_plan)
        user.cancel_subscription_plan
        #We remove the plan when Stripe says it's canceled so they get what they paid for.
        user.subscription_plan.should == subscription_plan
      end

      it "should get current information from Stripe" do
        FakeWeb.register_uri(:get, "https://api.stripe.com/v1/customers/123456", {body: '{"account_balance": 0,"created": 1330717999,"description": "user5","email": "user5@example.com","id": "123456","livemode": false,"object": "customer","active_card": {"country": "US","cvc_check": "pass","exp_month": 1,"exp_year": 2015,"last4": "4242","object": "card","type": "Visa"},"discount": {"end": 1333401541,"id": "di_HJZlbeDqk9TQOk","object": "discount","start": 1330723141,"coupon": {"duration": "once","id": "coupon-1","livemode": false,"max_redemptions": 20,"object": "coupon","percent_off": 10,"redeem_by": 1333238399,"times_redeemed": 2}},"next_recurring_charge": {"amount": 14016,"date": "2012-04-02"},"subscription": {"current_period_end": 1333396400,"current_period_start": 1330718000,"customer": "123456","object": "subscription","start": 1330730991,"status": "active","plan": {"amount": 10000,"currency": "usd","id": "gold","interval": "month","livemode": false,"name": "Gold","object": "plan"}}}', status: ["200", "OK"]})
        user = Factory(:user, vault_token: '123456')
        user.current_status.account_balance.should == 0
        user.current_status.id.should == '123456'
        user.current_status.discount.coupon.id.should == 'coupon-1'
        user.current_status.subscription.plan.id == 'gold'
      end
    end

    describe "#coupon_code" do
      it "should return the related coupon_code if a coupon exists" do
        @user = Factory(:user)
        @coupon = Factory(:coupon)
        @user.coupon = @coupon
        @user.coupon_code.should == @coupon.coupon_code
      end

      it "should return nil if there is no coupon" do
        @user = Factory(:user)
        @user.coupon_code.should == nil
      end

      it "should assign nil when assigned an invalid code" do
        @user = Factory(:user)
        @coupon = Factory(:coupon)
        @user.coupon_code = 'x'
        @user.coupon_code.should be_nil
        @user.coupon.should be_nil
      end

      it "should assign the coupon if applicable to plan" do
        @subscription_plan = Factory(:subscription_plan)
        @user = Factory(:user, subscription_plan: @subscription_plan)
        @coupon = Factory(:coupon, subscription_plans: [@subscription_plan])
        @user.coupon_code = @coupon.coupon_code
        @user.coupon_code.should == @coupon.coupon_code
        @user.coupon.should == @coupon
      end

      it "should not assign the coupon if not applicable to plan" do
        @subscription_plan = Factory(:subscription_plan)
        @user = Factory(:user, subscription_plan: @subscription_plan)
        @coupon = Factory(:coupon)
        @user.coupon_code = @coupon.coupon_code
        @user.coupon_code.should_not == @coupon.coupon_code
        @user.coupon.should_not == @coupon
      end

      it "should not assign the coupon if the user has no plan" do
        @user = Factory(:user)
        @coupon = Factory(:coupon)
        @user.coupon_code = @coupon.coupon_code
        @user.coupon_code.should_not == @coupon.coupon_code
        @user.coupon.should_not == @coupon
      end
    end

    describe "#subscription_active?" do
      it "should respond true if a valid subscription is in place" do
        subscription_plan = Factory(:subscription_plan)
        user = Factory(:user, subscription_plan: subscription_plan)
        user.subscription_active?.should be_true
      end

      it "should respond false if a valid subscription is not in place" do
        user = Factory(:user)
        user.subscription_active?.should be_false
      end
    end

    context "when performing metered actions" do
      before :each do
        @subscription_plan = Factory(:subscription_plan, included_units: 5, overage_price: 10)
        @user = Factory(:user, subscription_plan: @subscription_plan)
      end

      it "should have a unit_usage" do
        @user.unit_usage.should_not be_nil
      end

      it "should increment the unit_usage" do
        current = @user.unit_usage
        @user.use_unit.should == current + 1
      end

      it "should reset the unit_usage" do
        @user.use_unit
        current = @user.unit_usage
        final_val = @user.reset_usage
        current.should == final_val
        @user.unit_usage.should == 0
      end

      it "should determine if usage is over" do
        6.times { @user.use_unit }
        @user.over_limit?.should be_true
      end

      it "should have the overage_units" do
        6.times { @user.use_unit }
        @user.overage_units.should == 1
      end

      it "should have the overage_cost" do
        7.times { @user.use_unit }
        @user.overage_cost.should == 20
      end
    end

    context "when reseting the password" do
      it "should ask for a forgot password mail to be sent" do
        user = Factory(:user)
        user.deliver_reset_password_instructions
        Resque.size(:password_reset_mailer).should == 1
      end
    end
  end

end