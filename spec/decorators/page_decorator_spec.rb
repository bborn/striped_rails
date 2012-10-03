require 'spec_helper'

module StripedRails
  
  describe PageDecorator, :draper_with_helpers do
    include Rails.application.routes.url_helpers

    describe "#menu" do
      context "when we have 5 pages" do
        before :each do
          @pages = (1..5).map { PageDecorator.new(Factory(:page)) }
        end

        it "should produce a menu with a top level title element" do
          @pages.first.menu(@pages).should include "<a href=\"#\" class=\"dropdown-toggle\""
        end

        it "should produce menu items for each page" do
          @pages.first.menu(@pages).should include @pages[0].title
          @pages.first.menu(@pages).should include @pages[1].title
        end
      end
    end

  end

end