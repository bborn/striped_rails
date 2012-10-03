require 'spec_helper'
require 'fakeweb'

module StripedRails
  describe SubscriptionPlan do
    
    context "when validating attributes" do
      before :each do
        @subscription_plan = Factory.build(:subscription_plan)
      end

      it "should be valid with default factory attributes" do
        @subscription_plan.should be_valid
      end

      it "should be invalid without a vault token" do
        @subscription_plan.vault_token = nil
        @subscription_plan.should be_invalid
      end

      it "should be invalid without a plan name" do
        @subscription_plan.name = nil
        @subscription_plan.should be_invalid
      end

      it "should be invalid without a currency" do
        @subscription_plan.currency = nil
        @subscription_plan.should be_invalid
      end

      it "should be invalid without a price" do
        @subscription_plan.amount = nil
        @subscription_plan.should be_invalid
      end

      it "should be invalid without an interval" do
        @subscription_plan.interval = nil
        @subscription_plan.should be_invalid
      end

      it "should be invalid without a number of trial period days" do
        @subscription_plan.trial_period_days = nil
        @subscription_plan.should be_invalid
      end

      it "should be invalid with a vault_token longer than 255 characters" do
        @subscription_plan.vault_token = 'x'*256
        @subscription_plan.should be_invalid
      end

      it "should be invalid with a vault_token containing non alpha-numerics, '-' is ok" do
        @subscription_plan.vault_token = 'x -3'
        @subscription_plan.should be_invalid
      end

      it "should be invalid with a plan name longer than 255 characters" do
        @subscription_plan.name = 'x'*256
        @subscription_plan.should be_invalid
      end

      it "should be invalid with a currency not 3 characters" do
        @subscription_plan.currency = 'x'*4
        @subscription_plan.should be_invalid
        @subscription_plan.currency = 'x'*2
        @subscription_plan.should be_invalid
      end

      it "should be invalid with a currency containing non alpha" do
        @subscription_plan.currency = 'x x'
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless amount is a number" do
        @subscription_plan.amount = 'five'
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless amount is >= 0" do
        @subscription_plan.amount = -1
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless amount is an integer" do
        @subscription_plan.amount = 1.1
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless interval is month or year" do
        @subscription_plan.interval = "week"
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless trial period days is a number" do
        @subscription_plan.trial_period_days = 'five'
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless trial period days is >= 0" do
        @subscription_plan.trial_period_days = -1
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless trial period days is an integer" do
        @subscription_plan.trial_period_days = 1.1
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless included_units is a number" do
        @subscription_plan.included_units = 'x'
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless unless included_units is an integer" do
        @subscription_plan.included_units = 1.1
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless included_units >= 0" do
        @subscription_plan.included_units = -1
        @subscription_plan.should be_invalid
      end

      it "should be valid when included_units is nil" do
        @subscription_plan.included_units = nil
        @subscription_plan.should be_valid
      end

      it "should be invalid unless overage_price is a number" do
        @subscription_plan.overage_price = 'x'
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless unless overage_price is an integer" do
        @subscription_plan.overage_price = 1.1
        @subscription_plan.should be_invalid
      end

      it "should be invalid unless overage_price >= 0" do
        @subscription_plan.overage_price = -1
        @subscription_plan.should be_invalid
      end

      it "should be valid when overage_price is nil" do
        @subscription_plan.overage_price = nil
        @subscription_plan.should be_valid
      end
    end

    context "when mass assigning attributes" do
      before :each do
        @assignable = {stripe_id: 'x', name: 'x', currency: 'xxx', amount: 0, interval: 'month', trial_period_days: 0}
        @subscription_plan = Factory(:subscription_plan)
      end

      it "should allow assignable attributes to be mass assigned" do
        lambda{@subscription_plan.attributes = @attributes}.should_not raise_error
      end
    end

    describe "#update_stripe_plans" do
      before :each do
        FakeWeb.register_uri(:get, "https://api.stripe.com/v1/plans", body: '{ "count": 3, "data": [ { "currency": "usd", "object": "plan", "amount": 1000, "name": "Plan 1", "id": "plan-1", "interval": "month", "trial_period_days": 30 }, { "currency": "usd", "object": "plan", "amount": 2000, "name": "Plan 2", "id": "plan-2", "interval": "month", "trial_period_days": null }, { "currency": "usd", "object": "plan", "amount": 9900, "name": "Plan 3", "id": "plan-3", "interval": "year", "trial_period_days": null } ] }')
      end

      it "should update the plans from stripe" do
        SubscriptionPlan.update_stripe_plans
        plans = SubscriptionPlan.all
        plans.size.should == 3
        plans[0].name.should == "Plan 1"
      end

      it "should remove stale plans" do
        oplan = Factory(:subscription_plan, vault_token: 'plan-4')
        plans = SubscriptionPlan.all
        plans.size.should == 1
        SubscriptionPlan.update_stripe_plans
        SubscriptionPlan.exists?('plan-4').should be_false
      end
    end

    describe "#has_trial?" do
      it "should respond true when there is a trial period" do
        plan = Factory(:subscription_plan)
        plan.has_trial?.should be_true
      end

      it "should respond false when there is no trial period" do
        plan = Factory(:subscription_plan, trial_period_days: 0)
        plan.has_trial?.should be_false
      end
    end

    context "when scoping" do
      it "should order by price" do
        plan1 = Factory(:subscription_plan, amount: 2000)
        plan2 = Factory(:subscription_plan, amount: 1000)
        SubscriptionPlan.by_amount.first.should == plan2
      end

      it "should return only available plans" do
        plan1 = Factory(:subscription_plan, unavailable: false)
        plan2 = Factory(:subscription_plan, unavailable: true)
        SubscriptionPlan.available.should include plan1
        SubscriptionPlan.available.should_not include plan2
      end
    end

    it "should have many users" do
      subscription_plan = Factory(:subscription_plan)
      user1 = Factory(:user)
      user2 = Factory(:user)
      user1.subscription_plan = subscription_plan
      user1.save
      user2.subscription_plan = subscription_plan
      user2.save

      subscription_plan.users.should include user1
      subscription_plan.users.should include user2
    end

    context "when working with coupons" do
      before :each do
        @subscription_plan = Factory(:subscription_plan)
        @coupon1 = Factory(:coupon)
        @coupon2 = Factory(:coupon)
        @map1 = CouponSubscriptionPlan.create(coupon: @coupon1, subscription_plan: @subscription_plan)
        @map2 = CouponSubscriptionPlan.create(coupon: @coupon2, subscription_plan: @subscription_plan)
      end

      it "should have many coupon_subscription_plans" do
        @subscription_plan.coupon_subscription_plans.should include @map1
        @subscription_plan.coupon_subscription_plans.should include @map2
      end

      it "should have many coupons" do
        @subscription_plan.coupons.should include @coupon1
        @subscription_plan.coupons.should include @coupon2
      end
    end

    context "when destroying a subscription_plan" do
      it "should remove the subscription_plan from the users" do
        subscription_plan = Factory(:subscription_plan)
        user1 = Factory(:user)
        user2 = Factory(:user)
        user1.subscription_plan = @subscription_plan
        user1.save
        user2.subscription_plan = @subscription_plan
        user2.save
        subscription_plan.destroy
        user1.reload
        user2.reload

        user1.subscription_plan_id.should be_nil
        user2.subscription_plan_id.should be_nil
      end
    end

    describe "#monthly_revenue" do
      it "should calculate the revenue per month" do
        subscription_plan = Factory(:subscription_plan, amount: 1000)
        user1 = Factory(:user)
        user2 = Factory(:user)
        user1.subscription_plan = subscription_plan
        user1.save
        user2.subscription_plan = subscription_plan
        user2.save
        subscription_plan.reload

        subscription_plan.monthly_revenue.should == 2000
      end
    end

  end
end