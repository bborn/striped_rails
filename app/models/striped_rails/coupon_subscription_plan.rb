module StripedRails
  class CouponSubscriptionPlan < ActiveRecord::Base
    attr_accessible :coupon, :subscription_plan, :coupon_id, :subscription_plan_id
    validates_presence_of :coupon_id, :subscription_plan_id
    belongs_to :coupon
    belongs_to :subscription_plan
  end
end