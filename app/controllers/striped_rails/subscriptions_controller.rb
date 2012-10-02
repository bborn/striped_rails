module StripedRails
  class SubscriptionsController < BaseController

    def update
      @subscription_plan = SubscriptionPlan.find(params[:subscription_plan_id])
      
      respond_to do |format|
        if current_user.switch_subscription_plan(@subscription_plan)
          format.html { redirect_to profile_path, notice: 'Subscription plan switched. Your bill will be prorated.' }
        else
          flash[:error] = "There was a problem switching your subscription. Please try again later."
          format.html { redirect_to available_subscription_plans_path }
        end
      end
    end

    def destroy
      respond_to do |format|
        if current_user.cancel_subscription_plan
          format.html { redirect_to profile_path, notice: 'Subscription Canceled. We are sorry to see you go. You will still have access until the end of your billing cycle.' }
        else
          flash[:error] = "There was a problem canceling your subscription. Please try again later."
          format.html { redirect_to profile_path }
        end
      end
    end
  end
end