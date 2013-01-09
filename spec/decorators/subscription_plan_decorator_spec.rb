require 'spec_helper'

module StripedRails
  describe SubscriptionPlanDecorator, :draper_with_helpers do
    include StripedRails::Engine.routes.url_helpers

    describe "#price" do
      it "should provide the price in currency format" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan, amount: 999))
        subscription_plan.price.should == "$9.99 per month"
      end
    end

    describe "#monthly_revenue" do
      it "should format the monthly_revenue" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan, amount: 1000))
        subscription_plan.monthly_revenue.should == "$0.00"
      end
    end

    describe "#users_count" do
      it "should format the users_count" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan))
        subscription_plan.users_count.should == "0 Users"
      end
    end

    describe "#trial_information" do
      it "should provide human readable trial information" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan, trial_period_days: 30))
        subscription_plan.trial_information.should == '<p><span class="label label-success">30 day free trial!</span></p>'
      end

      it "should return an empty string when no trial" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan, trial_period_days: 0))
        subscription_plan.trial_information.should == ""
      end
    end

    describe "#unit_information" do
      it "should provide human readable unit information" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan, unit_name: 'Button Push', included_units: '10', overage_price: '10'))
        subscription_plan.unit_information.should include 'Button Push'
        subscription_plan.unit_information.should include '$0.10'
      end

      it "should return an empty string when unit usage is not being used" do
        subscription_plan = SubscriptionPlanDecorator.decorate(Factory(:subscription_plan))
        subscription_plan.unit_information.should == ''
      end
    end
  end

end