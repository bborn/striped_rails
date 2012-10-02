module StripedRails
  class BaseController < ::ApplicationController
    protect_from_forgery
    before_filter :load_pages
    before_filter :set_timezone
    before_filter :require_login
          
    layout :get_layout

  
    ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"field_with_errors\">#{html_tag}</span>".html_safe }

    private
      
      def get_layout
        StripedRails::Engine.config.layout = 'application'
        layout ||= StripedRails::Engine.config.layout
      end

      def load_pages
        @pages = PageDecorator.decorate(Page.ordered)
        @top_menu_page = @pages.first || PageDecorator.new(Page.new)
      end

      def set_timezone
        min = request.cookies["time_zone"].to_i
        Time.zone = ActiveSupport::TimeZone[-min.minutes]
      end

      def current_user
        cu = super
        if cu
          UserDecorator.decorate(cu)
        else
          UserDecorator.decorate(StripedRails::Engine.config.user_class.constantize.new)  
        end
      end

      def require_login
        not_authenticated unless current_user.signed_in?
      end

      def require_plan
        not_on_plan unless current_user.subscription_active?
      end

      def require_admin
        not_authorized unless current_user.admin?
      end

      def not_authenticated
        flash[:warning] = 'Please login or create an account.'
        redirect_to sign_in_path
      end

      def not_on_plan
        flash[:error] = 'You no longer have an active plan. You may choose a new plan if you wish to use the service.'
        redirect_to available_subscription_plans_path
      end

      def not_authorized
        flash[:error] = 'Not Authorized'
        redirect_to current_user.home_path
      end
  end
end