require "spec_helper"

module StripedRails

  describe CouponsController do
    describe "routing" do

      it "routes to #index" do
        get("/coupons").should route_to("coupons#index")
      end

      it "routes to #edit" do
        get("/coupons/1/edit").should route_to("coupons#edit", :id => "1")
      end

      it "routes to #update" do
        put("/coupons/1").should route_to("coupons#update", :id => "1")
      end

    end
  end

end