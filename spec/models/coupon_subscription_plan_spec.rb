require 'spec_helper'

module StripedRails
  describe CouponSubscriptionPlan do
    context "when validating attributes" do
      before :each do
        @coupon_subscription_plan = CouponSubscriptionPlan.new(coupon: Factory(:coupon), subscription_plan: Factory(:subscription_plan))
      end

      it "should be invalid without a coupon_id" do
        @coupon_subscription_plan.coupon_id = nil
        @coupon_subscription_plan.should be_invalid
      end

      it "should be invalid without a subscription_plan_id" do
        @coupon_subscription_plan.subscription_plan_id = nil
        @coupon_subscription_plan.should be_invalid
      end

      it "should have a coupon" do
        @coupon_subscription_plan.coupon.should_not be_nil
      end

      it "should have a subscription_plan" do
        @coupon_subscription_plan.subscription_plan.should_not be_nil
      end
    end
  end
end