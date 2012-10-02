module StripedRails
  class SubscriptionPlansController < BaseController
    skip_before_filter :require_login, only: [:available]
    before_filter :require_admin, except: [:available]

    def available
      @subscription_plans = SubscriptionPlanDecorator.decorate(SubscriptionPlan.available.by_amount)

      respond_to do |format|
        format.html
        format.json { render json: @subscription_plans }
      end
    end

    def index
      @subscription_plans = SubscriptionPlanDecorator.decorate(SubscriptionPlan.by_amount)

      respond_to do |format|
        format.html
        format.json { render json: @subscription_plans }
      end
    end

    def edit
      @subscription_plan = SubscriptionPlan.find(params[:id])
    end

    def update
      @subscription_plan = SubscriptionPlan.find(params[:id])

      respond_to do |format|
        if @subscription_plan.update_attributes(params[:subscription_plan])
          format.html { redirect_to subscription_plans_path, notice: 'Subscription plan was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @subscription_plan.errors, status: :unprocessable_entity }
        end
      end
    end

  end
end