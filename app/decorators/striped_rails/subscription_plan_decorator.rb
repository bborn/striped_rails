module StripedRails
  class SubscriptionPlanDecorator < BaseDecorator
    decorates :subscription_plan, :class => StripedRails::SubscriptionPlan

    def price
      "#{h.number_to_currency(subscription_plan.amount.to_f / 100)} per #{subscription_plan.interval}"
    end

    def trial_information
      if subscription_plan.trial_period_days > 0
        h.content_tag(:p,h.content_tag(:span,"#{subscription_plan.trial_period_days} day free trial!", class: 'label label-success'))
      else
        ''
      end
    end

    def name_and_price
      "#{name} (#{price})"
    end

    def monthly_revenue
      h.number_to_currency(subscription_plan.monthly_revenue.to_f / 100)
    end

    def users_count
      h.pluralize(subscription_plan.users_count,'User')
    end

    def description
      if subscription_plan.description?
        Haml::Engine.new(subscription_plan.description).render.html_safe
      else
        ''
      end
    end

    def unit_information
      if subscription_plan.unit_name?
        h.content_tag(:p, "Includes #{h.pluralize(h.number_with_delimiter(subscription_plan.included_units), subscription_plan.unit_name)}") +
        h.content_tag(:p, "Extra #{subscription_plan.unit_name.pluralize} are #{h.number_to_currency(subscription_plan.overage_price.to_f / 100)}")
      else
        ''
      end
    end
  end
end