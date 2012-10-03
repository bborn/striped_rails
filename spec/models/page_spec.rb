require 'spec_helper'


module StripedRails
  describe Page do

    context "when validating attributes" do
      before :each do
        @page = Factory.build(:page)
      end

      it "should be valid with default factory values" do
        @page.should be_valid
      end

      it "should be invalid without a title" do
        @page.title = nil
        @page.should be_invalid
      end

      it "should be invalid without a menu_order" do
        @page.menu_order = nil
        @page.should be_invalid
      end

      it "should be invalid without content" do
        @page.content = nil
        @page.should be_invalid
      end

      it "should be invalid with a title longer than 255 characters" do
        @page.title = 'x'*256
        @page.should be_invalid
      end

      it "should be invalid unless menu_order is a number" do
        @page.menu_order = 'five'
        @page.should be_invalid
      end
    end

    context "when mass assigning values" do
      before :each do
        @assignable = {title: 'Page X', content: 'Page X', menu_order: 10}
        @page = Factory(:page)
      end

      it "should allow mass assignment of assignable properties" do
        lambda{@page.attributes = @assignable}.should_not raise_error
      end

      it "should not allow mass assigning of slug" do
        lambda{@page.attributes = {slug: 'page-x'}}.should raise_error
      end
    end

    context "when scoping" do
      it "should order by menu_order" do
        @page1 = Factory(:page,menu_order: 2)
        @page2 = Factory(:page,menu_order: 1)
        Page.ordered.should == [@page2,@page1]
      end
    end
  end
end