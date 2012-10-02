module StripedRails
  class WebhookProcessor

    def process(event)
      data = JSON.parse(event) 
      eid = data["id"]
      trusted = Stripe::Event.retrieve(eid)
      data = trusted.data.object
      case trusted.type
      when "plan.created"
        SubscriptionPlan.create_or_update_from_stripe(data)
      when "plan.updated"
        SubscriptionPlan.create_or_update_from_stripe(data)
      when "plan.deleted"
        @plan = SubscriptionPlan.find_by_vault_token(data.id)
        @plan.destroy if @plan.present?
      when "coupon.created"
        Coupon.create_or_update_from_stripe(data)
      when "coupon.updated"
        Coupon.create_or_update_from_stripe(data)
      when "coupon.deleted"
        @coupon = Coupon.find_by_coupon_code(data.id)
        @coupon.destroy if @coupon.present?
      when "invoice.created"
        unless data.attempted
          unless data.lines.respond_to?(:invoiceitems)
            @user = User.find_by_vault_token(data.customer)
            @user.handle_overage
          end
        end
      when "invoice.payment_succeeded"
        @user = User.find_by_vault_token(data.customer)
        @user.deliver_invoice(data)
      when "invoice.payment_failed"
        @user = User.find_by_vault_token(data.customer)
        @user.deliver_invoice(data)
      when "customer.subscription.deleted"
        @user = User.find_by_vault_token(data.customer)
        @user.remove_subscription
      end
    end

  end
end