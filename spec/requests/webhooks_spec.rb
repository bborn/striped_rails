require 'spec_helper'
require 'fakeweb'

describe "Webhooks" do
  describe "POST /webhooks" do
    before :each do
      @event1 = '{"livemode": false, "type": "plan.created", "pending_webhooks": 0, "data": {"object": {"currency": "usd", "object": "plan", "amount": 1000, "name": "Plan 1", "id": "plan-1", "interval": "month", "trial_period_days": 30}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
      FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event1)
    end

    it "should create a plan when receiving a plan.created event" do
      post webhooks_path, @event1
      response.status.should be(200)
      SubscriptionPlan.exists?('plan-1').should be_true
    end
  end
end