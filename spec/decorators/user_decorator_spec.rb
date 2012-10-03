require 'spec_helper'

module StripedRails
  describe UserDecorator, :draper_with_helpers do
    include Rails.application.routes.url_helpers

    context "when session handling" do
      it "should not be signed_in? with a guest user" do
        UserDecorator.decorate(User.new).signed_in?.should be_false
      end

      it "should be signed_in? with a real user" do
        user = Factory(:user)
        UserDecorator.decorate(user).signed_in?.should be_true
      end

      it "should produce a link to sign_in with a guest user" do
        UserDecorator.decorate(User.new).session_control.should include 'Sign In'
      end

      it "should produce a link to sign_out with a real user" do
        user = Factory(:user)
        UserDecorator.decorate(user).session_control.should include 'Sign Out'
      end

      it "should produce a profile link for brand if signed in" do
        user = Factory(:user)
        UserDecorator.decorate(user).home_link('Brand').should include 'profile'
      end

      it "should produce a sign up button for subscription if not signed in" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan))
        UserDecorator.decorate(User.new).subscription_plan_button(subscription_plan).should include 'Sign Up'
      end

      it "should produce a switch button for a subscription if signed in" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan))
        user = Factory(:user)
        UserDecorator.decorate(user).subscription_plan_button(subscription_plan).should include 'Switch To'
      end

      it "should produce a button indicating existing plan if signed in with the subscription" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan))
        user = Factory(:user, subscription_plan: subscription_plan)
        UserDecorator.decorate(user).subscription_plan_button(subscription_plan).should include 'Your Plan'
      end

      it "should produce an edit button for a subscription if signed in as admin" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan))
        user = Factory(:user, is_admin: true)
        UserDecorator.decorate(user).subscription_plan_button(subscription_plan).should include 'Edit'
      end
    end

    it "should return the user's id with to_i" do
      @user = Factory(:user)
      UserDecorator.decorate(@user).to_i.should == @user.id
    end

    it "should return the user's overage_cost in currency format" do
      @subscription_plan = Factory(:subscription_plan, included_units: 5, overage_price: 10)
      @user = Factory(:user, subscription_plan: @subscription_plan)
      7.times { @user.use_unit }
      UserDecorator.decorate(@user).overage_cost.should == "$0.20"
    end
  end

end