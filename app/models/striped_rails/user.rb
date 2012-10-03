module StripedRails
  module User
    
    extend ActiveSupport::Concern

    included do
      belongs_to :subscription_plan, counter_cache: true, :class_name => "StripedRails::SubscriptionPlan"
      belongs_to :coupon, counter_cache: true, :class_name => "StripedRails::Coupon"
      after_save :update_stripe_customer

      attr_accessible :email, :full_name, :subscription_plan_id, :card_token, :coupon_code
      validates :email, :presence => true

      attr_accessor :card_token

    end


    def coupon_code=(val)
      coupon = Coupon.find_by_coupon_code(val)
      if coupon && coupon.subscription_plans.include?(subscription_plan)
        self.coupon = coupon
      end
      
      self.coupon_code
    end

    def coupon_code
      coupon.coupon_code if coupon.present?
    end

    def subscription_active?
      subscription_plan_id?
    end

    def last4
      customer = Stripe::Customer.retrieve(vault_token)
      if customer.active_card.present?
        customer.active_card.last4
      else
        nil
      end
    end

    def current_status
      @current_status ||= Stripe::Customer.retrieve(vault_token) if vault_token

      @current_status
    end

    def unit_usage
      Resque.redis.get("usage_meters:#{id}").to_i || 0
    end

    def use_unit
      Resque.redis.incr("usage_meters:#{id}").to_i
    end

    def reset_usage
      Resque.redis.getset("usage_meters:#{id}", 0).to_i
    end

    def included_units
      if subscription_plan_id? then subscription_plan.included_units else 0 end
    end

    def overage_units
      [unit_usage - included_units, 0].max
    end

    def over_limit?
      overage_units > 0
    end

    def overage_price
      if subscription_plan_id? then subscription_plan.overage_price else 0 end
    end

    def overage_cost
      overage_units * overage_price
    end

    def handle_overage
      if over_limit?
        add_overage_to_bill
      else
        reset_usage
      end
    end

    def create_stripe_customer
      if valid?
        customer = Stripe::Customer.create(email: email, description: full_name, plan: subscription_plan.vault_token, coupon: coupon_code, card: card_token)
        self.vault_token = customer.id
        save!
      end
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe Request error while creating user: #{e.message}"
      errors.add :base, "There was a problem with your credit card."
      false
    rescue Stripe::CardError => e
      logger.error "Stripe Card error while creating user: #{e.message}"
      errors.add :base, "There was a problem with your credit card."
      false
    rescue Stripe::AuthenticationError => e
      logger.error "Stripe Authentication error while creating user: #{e.message}"
      errors.add :base, "Our system is temporarily unable to process credit cards."
      false
    rescue Stripe::APIError => e
      logger.error "Stripe Authentication error while creating user: #{e.message}"
      errors.add :base, "Our system is temporarily unable to process credit cards."
      false
    end

    def update_credit_card
      if valid?
        customer = Stripe::Customer.retrieve(vault_token)
        customer.card = card_token
        customer.save
        true
      end
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe Request error while updating card: #{e.message}"
      errors.add :base, "There was a problem with your credit card."
      false
    rescue Stripe::CardError => expires
      logger.error "Stripe Card error while updating card: #{e.message}"
      errors.add :base, "There was a problem with your credit card."
      false
    rescue Stripe::AuthenticationError => e
      logger.error "Stripe Authentication error while updating card: #{e.message}"
      errors.add :base, "Our system is temporarily unable to process credit cards."
      false
    rescue Stripe::APIError => e
      logger.error "Stripe Authentication error while updating card: #{e.message}"
      errors.add :base, "Our system is temporarily unable to process credit cards."
      false
    end

    def switch_subscription_plan(new_plan)
      customer = Stripe::Customer.retrieve(vault_token)
      customer.update_subscription(plan: new_plan.vault_token)
      self.subscription_plan = new_plan
      save
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe Request error while switching plans: #{e.message}"
      false
    rescue Stripe::AuthenticationError => e
      logger.error "Stripe Authentication error while switching plans: #{e.message}"
      false
    rescue Stripe::APIError => e
      logger.error "Stripe Authentication error while switching plans: #{e.message}"
      false
    end

    def cancel_subscription_plan
      customer = Stripe::Customer.retrieve(vault_token)
      customer.cancel_subscription(at_period_end: true)
      true
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe Request error while canceling plan: #{e.message}"
      false
    rescue Stripe::AuthenticationError => e
      logger.error "Stripe Authentication error while canceling plan: #{e.message}"
      false
    rescue Stripe::APIError => e
      logger.error "Stripe Authentication error while canceling plan: #{e.message}"
      false
    end

    def deliver_invoice(invoice)
      ::Resque.enqueue(InvoiceMailer, id, invoice)
    end

    def remove_subscription
      self.subscription_plan = nil
      save
    end

    def to_i
      id
    end

    private


    def update_stripe_customer
      if email_changed? && !id_changed? && vault_token
        customer = Stripe::Customer.retrieve(vault_token)
        customer.email = email
        customer.save
        true
      end
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while updating user: #{e.message}"
      errors.add :base, "There was a problem updating your information with or credit card processor. Please try again later."
      false
    rescue Stripe::AuthenticationError => e
      logger.error "Stripe error while updating user: #{e.message}"
      errors.add :base, "There was a problem updating your information with or credit card processor. Please try again later."
      false
    rescue Stripe::APIError => e
      logger.error "Stripe error while updating user: #{e.message}"
      errors.add :base, "There was a problem updating your information with or credit card processor. Please try again later."
      false
    end

    def add_overage_to_bill
      billable = (reset_usage - subscription_plan.included_units)
      bill_amount = billable * subscription_plan.overage_price
      Stripe::InvoiceItem.create({
        customer: vault_token,
        amount: bill_amount,
        currency: subscription_plan.currency,
        description: "#{subscription_plan.unit_name} Overage"
      })
      true
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while adding invoiceitem of #{bill_amount} to #{full_name}: #{e.message}"
      false
    rescue Stripe::AuthenticationError => e
      logger.error "Stripe error while adding invoiceitem of #{bill_amount} to #{full_name}: #{e.message}"
      false
    rescue Stripe::APIError => e
      logger.error "Stripe error while adding invoiceitem of #{bill_amount} to #{full_name}: #{e.message}"
      false
    end


  end
end