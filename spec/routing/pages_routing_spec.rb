require "spec_helper"

module StripedRails
  describe PagesController do
    describe "routing" do

      before(:each) { @routes = StripedRails::Engine.routes }

      it "routes to #index" do
        get("/").should route_to("striped_rails/pages#index")
      end

      it "routes to #new" do
        get("/pages/new").should route_to("striped_rails/pages#new")
      end

      it "routes to #show" do
        get("/pages/1").should route_to("striped_rails/pages#show", :id => "1")
      end

      it "routes to #edit" do
        get("/pages/1/edit").should route_to("striped_rails/pages#edit", :id => "1")
      end

      it "routes to #create" do
        post("/pages").should route_to("striped_rails/pages#create")
      end

      it "routes to #update" do
        put("/pages/1").should route_to("striped_rails/pages#update", :id => "1")
      end

      it "routes to #destroy" do
        delete("/pages/1").should route_to("striped_rails/pages#destroy", :id => "1")
      end

    end
  end
end