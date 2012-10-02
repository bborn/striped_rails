module StripedRails
  class UsersController < BaseController
    before_filter :load_subscription_plans, only: [:subscribe, :create_subscription]
    before_filter :require_admin, except: [:subscribe, :create_subscription]

    def index
      @users = UserDecorator.all

      respond_to do |format|
        format.html
        format.json { render json: @users }
      end
    end

    def show
      @user = UserDecorator.find(params[:id])

      respond_to do |format|
        format.html
        format.json { render json: @user }
      end
    end

    def subscribe
      @subscription_plan = SubscriptionPlan.find(params[:subscription_plan_id]) if params[:subscription_plan_id]
      @subscription_plan ||= SubscriptionPlan.by_amount.first
      @user = current_user.model
      @user.subscription_plan = @subscription_plan if @subscription_plan
      
      respond_to do |format|
        format.html
        format.json { render json: @user }
      end
    end

    def edit
      @user = StripedRails::Engine.user.find(params[:id])
    end

    def create_subscription
      @user = current_user.model
      @user.attributes = params[:user]

      respond_to do |format|
        if @user.create_stripe_customer
          format.html { redirect_to profile_path, notice: 'Account Created! Welcome to Brand!' }
          format.json { render json: @user, status: :created, location: @user }
        else
          format.html { render action: "subscribe" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      @user = StripedRails::Engine.user.find(params[:id])
      @user.is_admin = params[:user].delete(:is_admin)

      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to @user, notice: 'User was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @user = StripedRails::Engine.user.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html { redirect_to users_url }
        format.json { head :no_content }
      end
    end

    private
    def load_subscription_plans
      @subscription_plans = SubscriptionPlanDecorator.decorate(SubscriptionPlan.by_amount)
    end

  end
end