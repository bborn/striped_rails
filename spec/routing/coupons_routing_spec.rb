require "spec_helper"

module StripedRails

  describe CouponsController do
    describe "routing" do
      
      before(:each) { @routes = StripedRails::Engine.routes }      

      it "routes to #index" do
        get("/coupons").should route_to("striped_rails/coupons#index")
      end

      it "routes to #edit" do
        get("/coupons/1/edit").should route_to("striped_rails/coupons#edit", :id => "1")
      end

      it "routes to #update" do
        put("/coupons/1").should route_to("striped_rails/coupons#update", :id => "1")
      end

    end
  end

end