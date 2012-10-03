require "spec_helper"

module StripedRails
  describe UsersController do
    describe "routing" do

      before(:each) { @routes = StripedRails::Engine.routes }

      it "routes to #index" do
        get("/users").should route_to("striped_rails/users#index")
      end

      it "routes to #edit" do
        get("/users/1/edit").should route_to("striped_rails/users#edit", :id => "1")
      end

      it "routes to #update" do
        put("/users/1").should route_to("striped_rails/users#update", :id => "1")
      end

      it "routes to #destroy" do
        delete("/users/1").should route_to("striped_rails/users#destroy", :id => "1")
      end

      it "routes to #subscribe" do
        get("/subscribe").should route_to("striped_rails/users#subscribe")
      end

      it "routes to #create_subscription" do
        post("/subscribe").should route_to("striped_rails/users#create_subscription")
      end


    end
  end

end