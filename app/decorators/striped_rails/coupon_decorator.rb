module StripedRails
  class CouponDecorator < BaseDecorator
    decorates :coupon, :class => StripedRails::Coupon

    def percent_off
      "#{coupon.percent_off}% Off"
    end

    def expiration
      if coupon.redeem_by?
        coupon.redeem_by.strftime("%Y-%m-%d")
      else
        'No expiration'
      end
    end

    def applicable_plans
      coupon.subscription_plans.map {|p| p.name}.join(',')
    end
  end
end