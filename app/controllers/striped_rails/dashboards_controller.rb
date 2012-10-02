module StripedRails
  class DashboardsController < BaseController
    before_filter :require_admin

    def show
      @users_count = StripedRails::Engine.user.count
      @subscription_plans = SubscriptionPlanDecorator.decorate(SubscriptionPlan.by_amount)
    end
  end
end