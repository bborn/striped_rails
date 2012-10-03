require 'spec_helper'

FakeWeb.allow_net_connect = false

module StripedRails
  describe Coupon do
    context "with friendly_id" do
      it "to_param should return the coupon_code" do
        @coupon = Factory(:coupon)
        @coupon.to_param.should == @coupon.coupon_code
      end
    end

    context "when validating attributes" do
      before :each do
        @coupon = Factory.build(:coupon)
      end

      it "should be valid with default Factory attributes" do
        @coupon.should be_valid
      end

      it "should be invalid without a coupon_code" do
        @coupon.coupon_code = nil
        @coupon.should be_invalid
      end

      it "should be invalid without a percent_off" do
        @coupon.percent_off = nil
        @coupon.should be_invalid
      end

      it "should be invalid without a duration" do
        @coupon.duration = nil
        @coupon.should be_invalid
      end

      it "should be invalid with a coupon_code longer than 20 characters" do
        @coupon.coupon_code = 'x'*21
        @coupon.should be_invalid
      end

      it "should be invalid with a coupon_code containing non alphanumerics and -" do
        @coupon.coupon_code = 'x 1-'
        @coupon.should be_invalid
      end

      it "should be invalid with a duplicate coupon_code" do
        @coupon1 = Factory(:coupon, coupon_code: 'code-1')
        @coupon2 = Factory.build(:coupon, coupon_code: 'code-1')
        @coupon2.should be_invalid
      end

      it "should be invalid without a numeric percent_off" do
        @coupon.percent_off = 'x'
        @coupon.should be_invalid
      end

      it "should be invalid without an integer percent_off" do
        @coupon.percent_off = 1.1
        @coupon.should be_invalid
      end

      it "should be invalid with an integer greater than 100" do
        @coupon.percent_off = 101
        @coupon.should be_invalid
      end

      it "should be invalid with an integer less than 0" do
        @coupon.percent_off = -1
        @coupon.should be_invalid
      end

      it "should be invalid with a duration other than once, repeat, forever" do
        @coupon.duration = 'x'
        @coupon.should be_invalid
      end

      it "should be invalid without a numeric duration_in_months" do
        @coupon.duration_in_months = 'x'
        @coupon.should be_invalid
      end

      it "should be invalid without an integer duration_in_months" do
        @coupon.duration_in_months = 1.1
        @coupon.should be_invalid
      end

      it "should be invalid without an duration_in_months greater than or equal to 0" do
        @coupon.duration_in_months = -1
        @coupon.should be_invalid
      end

      it "should be invalid without a numeric max_redemptions" do
        @coupon.max_redemptions = 'x'
        @coupon.should be_invalid
      end

      it "should be invalid without an integer max_redemptions" do
        @coupon.max_redemptions = 1.1
        @coupon.should be_invalid
      end

      it "should be invalid without a max_redemptions greater than or equal to 0" do
        @coupon.max_redemptions = -1
        @coupon.should be_invalid
      end

      it "should be invalid without a numeric times_redeemed" do
        @coupon.times_redeemed = 'x'
        @coupon.should be_invalid
      end

      it "should be invalid without an integer times_redeemed" do
        @coupon.times_redeemed = 1.1
        @coupon.should be_invalid
      end

      it "should be invalid without a times_redeemed greater than or equal to 0" do
        @coupon.times_redeemed = -1
        @coupon.should be_invalid
      end
    end

    it "should have many users" do
      @coupon = Factory(:coupon)
      @user1 = Factory(:user)
      @user2 = Factory(:user)
      @user1.coupon = @coupon
      @user1.save
      @user2.coupon = @coupon
      @user2.save

      @coupon.users.should include @user1
      @coupon.users.should include @user2
    end

    context "when working with subscription plans" do
      before :each do
        @coupon = Factory(:coupon)
        @subscription_plan1 = Factory(:subscription_plan)
        @subscription_plan2 = Factory(:subscription_plan)
        @map1 = CouponSubscriptionPlan.create(coupon: @coupon, subscription_plan: @subscription_plan1)
        @map2 = CouponSubscriptionPlan.create(coupon: @coupon, subscription_plan: @subscription_plan2)
      end

      it "should have many coupon_subscription_plans" do
        @coupon.coupon_subscription_plans.should include @map1
        @coupon.coupon_subscription_plans.should include @map2
      end

      it "should have many subscription_plans" do
        @coupon.subscription_plans.should include @subscription_plan1
        @coupon.subscription_plans.should include @subscription_plan2
      end
    end

    context "when destroying a coupon" do
      it "should remove the coupon from the users" do
        @coupon = Factory(:coupon)
        @user1 = Factory(:user)
        @user2 = Factory(:user)
        @user1.coupon = @coupon
        @user1.save
        @user2.coupon = @coupon
        @user2.save
        @coupon.destroy
        @user1.reload
        @user2.reload

        @user1.coupon_id.should be_nil
        @user2.coupon_id.should be_nil
      end
    end

    describe "#update_stripe_coupons" do
      before :each do
        FakeWeb.register_uri(:get, "https://api.stripe.com/v1/coupons", body: '{ "count": 3, "data": [ { "id": "coupon-1", "object": "coupon", "percent_off": 10, "duration": "once", "max_redemptions": 20, "redeem_by": 1330561208 }, { "id": "coupon-2", "object": "coupon", "percent_off": 20, "duration": "repeat", "duration_in_months": 6 }, { "id": "coupon-3", "object": "coupon", "percent_off": 30, "duration": "forever" } ] }')
      end

      it "should update the coupons from stripe" do
        Coupon.update_stripe_coupons
        @coupons = Coupon.all
        @coupons.size.should == 3
        @coupons[0].coupon_code.should == "coupon-1"
      end

      it "should remove stale coupons" do
        @ocoupon = Factory(:coupon, coupon_code: 'coupon-4')
        @coupons = Coupon.all
        @coupons.size.should == 1
        Coupon.update_stripe_coupons
        Coupon.exists?('coupon-4').should be_false
      end
    end
  end

end