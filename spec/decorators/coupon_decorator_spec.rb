require 'spec_helper'

module StripedRails
  describe CouponDecorator do
    before { BaseController.new.set_current_view_context }
  end
end