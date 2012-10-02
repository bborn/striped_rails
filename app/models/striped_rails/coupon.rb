module StripedRails
  class Coupon < ActiveRecord::Base
    extend FriendlyId
    friendly_id :coupon_code

    attr_accessible :coupon_code, :percent_off, :duration, :duration_in_months, :redeem_by, :max_redemptions, :times_redeemed, :coupon_subscription_plans, :coupon_subscription_plan_ids, :subscription_plans, :subscription_plan_ids
    validates_presence_of :coupon_code, :percent_off, :duration
    validates_length_of :coupon_code, in: 1..20
    validates_format_of :coupon_code, with: /\A[a-z0-9\-]+\Z/i
    validates_uniqueness_of :coupon_code
    validates_numericality_of :percent_off, only_integer: true, less_than_or_equal_to: 100, greater_than_or_equal_to: 0
    validates_format_of :duration, with: /\A(once|repeat|forever)\Z/
    validates_numericality_of :duration_in_months, allow_nil: true, only_integer: true, greater_than_or_equal_to: 0
    validates_numericality_of :max_redemptions, allow_nil: true, only_integer: true, greater_than_or_equal_to: 0
    validates_numericality_of :times_redeemed, allow_nil: true, only_integer: true, greater_than_or_equal_to: 0
    has_many :users
    has_many :coupon_subscription_plans, dependent: :destroy
    has_many :subscription_plans, through: :coupon_subscription_plans
    after_destroy :scrub_users

    def self.create_or_update_from_stripe(data)
      coupon = Coupon.where(coupon_code: data.id).first_or_initialize
      data_hash = data.to_hash.slice(:percent_off,:duration,:duration_in_months,:max_redemptions,:redeem_by)
      data_hash[:redeem_by] = Time.at(data_hash[:redeem_by]) if data_hash[:redeem_by]
      coupon.update_attributes(data_hash)
    end

    def self.update_stripe_coupons
      result = true
      original_ids = Coupon.pluck(:coupon_code)
      current_coupons = Stripe::Coupon.all
      result = Coupon.update_from_stripe_data(current_coupons.data)
      result = Coupon.remove_stale_coupons(original_ids,current_coupons.data)
      result
    end

    private
    def self.update_from_stripe_data(coupons)
      result = true
      coupons.each do |c|
        result = Coupon.create_or_update_from_stripe(c)
      end

      result
    end

    def self.remove_stale_coupons(originals,coupons)
      result = true
      ids = Coupon.extract_coupon_ids_from_stripe_data(coupons)
      originals.each do |id|
        if !ids.index(id)
          result = Coupon.find(id).destroy
        end
      end

      result
    end

    def self.extract_coupon_ids_from_stripe_data(coupons)
      coupons.map { |c| c.id }
    end

    def scrub_users
      self.users.each do |user|
        user.coupon = nil
        user.save
      end
    end
  end
end