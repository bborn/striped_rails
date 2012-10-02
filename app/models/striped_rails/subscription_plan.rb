module StripedRails
  class SubscriptionPlan < ActiveRecord::Base
    extend FriendlyId
    friendly_id :vault_token
    attr_accessible :vault_token, :name, :currency, :amount, :interval, :trial_period_days, :unit_name, :included_units, :overage_price, :description, :unavailable
    validates_presence_of :vault_token, :name, :currency, :amount, :interval, :trial_period_days
    validates_length_of :vault_token, in: 1..255
    validates_format_of :vault_token, with: /\A[a-z0-9\-]+\Z/i
    validates_length_of :name, in: 1..255
    validates_length_of :currency, is: 3
    validates_format_of :currency, with: /\A[a-z]+\Z/
    validates_format_of :interval, with: /\A(month|year)\Z/
    validates_numericality_of :amount, greater_than_or_equal_to: 0, only_integer: true 
    validates_numericality_of :trial_period_days, greater_than_or_equal_to: 0, only_integer: true
    validates_numericality_of :included_units, only_integer: true, greater_than_or_equal_to: 0, allow_nil: true
    validates_numericality_of :overage_price, only_integer: true, greater_than_or_equal_to: 0, allow_nil: true
    scope :by_amount, order(:amount)
    scope :available, where(unavailable: false)
    has_many :users
    has_many :coupon_subscription_plans, dependent: :destroy
    has_many :coupons, through: :coupon_subscription_plans, dependent: :destroy
    after_destroy :scrub_users

    def has_trial?
      trial_period_days > 0
    end

    def monthly_revenue
      amount * users_count
    end

    def self.update_stripe_plans
      result = true
      original_ids = SubscriptionPlan.pluck(:vault_token)
      current_plans = Stripe::Plan.all
      result = SubscriptionPlan.update_from_stripe_data(current_plans.data)
      result = SubscriptionPlan.remove_stale_plans(original_ids,current_plans.data)
      result
    end

    def self.create_or_update_from_stripe(data)
      plan = SubscriptionPlan.where(vault_token: data.id).first_or_initialize
      data_hash = data.to_hash.slice(:amount,:interval,:name,:currency,:trial_period_days)
      data_hash[:trial_period_days] ||= 0
      plan.update_attributes(data_hash)
    end

    private
    def self.update_from_stripe_data(plans)
      result = true
      plans.each do |p|
        result = SubscriptionPlan.create_or_update_from_stripe(p)
      end

      result
    end

    def self.remove_stale_plans(originals,plans)
      result = true
      ids = SubscriptionPlan.extract_plan_ids_from_stripe_data(plans)
      originals.each do |id|
        if !ids.index(id)
          result = SubscriptionPlan.find(id).destroy
        end
      end

      result
    end

    def self.extract_plan_ids_from_stripe_data(plans)
      plans.map { |p| p.id }
    end

    def scrub_users
      self.users.each do |user|
        user.subscription_plan = nil
        user.save
      end
    end

  end
end