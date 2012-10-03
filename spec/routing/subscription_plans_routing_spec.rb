require "spec_helper"

module StripedRails
  describe SubscriptionPlansController do
    describe "routing" do

      before(:each) { @routes = StripedRails::Engine.routes }

      it "routes to #available" do
        get("/subscription_plans/available").should route_to("striped_rails/subscription_plans#available")
      end

      it "routes to #index" do
        get("/subscription_plans").should route_to("striped_rails/subscription_plans#index")
      end

      it "routes to #edit" do
        get("/subscription_plans/1/edit").should route_to("striped_rails/subscription_plans#edit", :id => "1")
      end

      it "routes to #update" do
        put("/subscription_plans/1").should route_to("striped_rails/subscription_plans#update", :id => "1")
      end

    end
  end
end