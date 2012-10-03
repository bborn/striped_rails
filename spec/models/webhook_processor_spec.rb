require 'spec_helper'
require 'fakeweb'


module StripedRails
  describe WebhookProcessor do

    before :each do
      @processor = WebhookProcessor.new
    end

    describe "#process" do
      context "when a plan is created" do
        before :each do
          @event1 = '{"livemode": false, "type": "plan.created", "pending_webhooks": 0, "data": {"object": {"currency": "usd", "object": "plan", "amount": 1000, "name": "Plan 1", "id": "plan-1", "interval": "month", "trial_period_days": 30}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
          @event2 = '{"livemode": false, "type": "plan.created", "pending_webhooks": 0, "data": {"object": {"currency": "usd", "object": "plan", "amount": 8000, "name": "Plan 2", "id": "plan-2", "interval": "year"}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ6", "created": 1328912769}'
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event1)
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ6", body: @event2)
        end

        it "should create a new monthly subscription plan locally" do
          @processor.process(@event1)
          SubscriptionPlan.exists?('plan-1').should be_true
        end

        it "should create a new yearly subscription plan locally" do
          @processor.process(@event2)
          SubscriptionPlan.exists?('plan-2').should be_true
        end
      end

      context "when a plan is updated" do
        before :each do
          @plan1 = Factory(:subscription_plan, vault_token: 'plan-1', amount: 0)
          @plan2 = Factory(:subscription_plan, vault_token: 'plan-2', amount: 0)
          @event1 = '{"livemode": false, "type": "plan.updated", "pending_webhooks": 0, "data": {"object": {"currency": "usd", "object": "plan", "amount": 1000, "name": "Plan 1", "id": "plan-1", "interval": "month", "trial_period_days": 30}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
          @event2 = '{"livemode": false, "type": "plan.updated", "pending_webhooks": 0, "data": {"object": {"currency": "usd", "object": "plan", "amount": 8000, "name": "Plan 2", "id": "plan-2", "interval": "year"}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ6", "created": 1328912769}'
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event1)
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ6", body: @event2)
        end

        it "should update an existing monthly subscription plan locally" do
          @processor.process(@event1)
          SubscriptionPlan.find('plan-1').amount.should == 1000
        end

        it "should update an existing yearly subscription plan locally" do
          @processor.process(@event2)
          SubscriptionPlan.find('plan-2').amount.should == 8000
        end
      end

      context "when a plan is deleted" do
        before :each do
          @plan1 = Factory(:subscription_plan, vault_token: 'plan-1')
          @plan2 = Factory(:subscription_plan, vault_token: 'plan-2')
          @event1 = '{"livemode": false, "type": "plan.deleted", "pending_webhooks": 0, "data": {"object": {"currency": "usd", "object": "plan", "amount": 1000, "name": "Plan 1", "id": "plan-1", "interval": "month", "trial_period_days": 30}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
          @event2 = '{"livemode": false, "type": "plan.deleted", "pending_webhooks": 0, "data": {"object": {"currency": "usd", "object": "plan", "amount": 8000, "name": "Plan 2", "id": "plan-2", "interval": "year"}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ6", "created": 1328912769}'
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event1)
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ6", body: @event2)
        end

        it "should delete an existing monthly subscription plan locally" do
          @processor.process(@event1)
          SubscriptionPlan.exists?('plan-1').should be_false
        end

        it "should delete an existing yearly subscription plan locally" do
          @processor.process(@event2)
          SubscriptionPlan.exists?('plan-2').should be_false
        end
      end

      context "when a coupon is created" do
        before :each do
          @event1 = '{"livemode": false, "type": "coupon.created", "pending_webhooks": 0, "data": {"object": {"percent_off": 10, "object": "coupon", "duration": "once", "id": "coupon-1", "max_redemptions": 20, "redeem_by": 1328912764}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
          @event2 = '{"livemode": false, "type": "coupon.created", "pending_webhooks": 0, "data": {"object": {"percent_off": 10, "object": "coupon", "duration": "repeat", "id": "coupon-2", "duration_in_months": 6}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ6", "created": 1328912764}'
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event1)
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ6", body: @event2)
        end

        it "should create a new one time coupon locally" do
          @processor.process(@event1)
          Coupon.exists?('coupon-1').should be_true
        end

        it "should create a new repeating coupon locally" do
          @processor.process(@event2)
          Coupon.exists?('coupon-2').should be_true
        end
      end

      context "when a coupon is updated" do
        before :each do
          @coupon1 = Factory(:coupon, coupon_code: 'coupon-1', percent_off: 0)
          @coupon2 = Factory(:coupon, coupon_code: 'coupon-2', percent_off: 0)
          @event1 = '{"livemode": false, "type": "coupon.updated", "pending_webhooks": 0, "data": {"object": {"percent_off": 10, "object": "coupon", "duration": "once", "id": "coupon-1", "max_redemptions": 20, "redeem_by": 1328912764}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
          @event2 = '{"livemode": false, "type": "coupon.updated", "pending_webhooks": 0, "data": {"object": {"percent_off": 10, "object": "coupon", "duration": "repeat", "id": "coupon-2", "duration_in_months": 6}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ6", "created": 1328912764}'
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event1)
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ6", body: @event2)
        end

        it "should update an existing one time coupon locally" do
          @processor.process(@event1)
          Coupon.find('coupon-1').percent_off.should == 10
        end

        it "should update an existing repeating coupon locally" do
          @processor.process(@event2)
          Coupon.find('coupon-2').percent_off.should == 10
        end
      end

      context "when a coupon is deleted" do
        before :each do
          @coupon1 = Factory(:coupon, coupon_code: 'coupon-1', percent_off: 0)
          @coupon2 = Factory(:coupon, coupon_code: 'coupon-2', percent_off: 0)
          @event1 = '{"livemode": false, "type": "coupon.deleted", "pending_webhooks": 0, "data": {"object": {"percent_off": 10, "object": "coupon", "duration": "once", "id": "coupon-1", "max_redemptions": 20, "redeem_by": 1328912764}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
          @event2 = '{"livemode": false, "type": "coupon.deleted", "pending_webhooks": 0, "data": {"object": {"percent_off": 10, "object": "coupon", "duration": "repeat", "id": "coupon-2", "duration_in_months": 6}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ6", "created": 1328912764}'
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event1)
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ6", body: @event2)
        end

        it "should delete an existing one time coupon locally" do
          @processor.process(@event1)
          Coupon.exists?('coupon-1').should be_false
        end

        it "should delete an existing repeating coupon locally" do
          @processor.process(@event2)
          Coupon.exists?('coupon-2').should be_false
        end
      end

      context "when an invoice is generated" do
        before :each do
          @subscription_plan = Factory(:subscription_plan, vault_token: 'plan-1', unit_name: 'Button Push', included_units: 10, overage_price: 10)
          @user = Factory(:user, vault_token: '123456', subscription_plan: @subscription_plan)
          @event = '{"livemode": false, "type": "invoice.created", "pending_webhooks": 0, "data": {"object": {"subtotal": 1000, "attempted": false, "total": 1000, "next_payment_attempt": 1330576104, "period_start": 1330576104, "customer": "123456", "date": 1330576104, "lines": {"subscriptions": [{"amount": 1000, "plan": {"interval": "month", "trial_period_days": 30, "object": "plan", "amount": 1000, "name": "Bronze", "id": "bronze", "livemode": false, "currency": "usd"}, "period": {"end": 1333168104, "start": 1330576104}}]}, "paid": false, "discount": {"coupon": {"redeem_by": 1333238399, "duration": "once", "times_redeemed": 1, "object": "coupon", "percent_off": 10, "id": "coupon-1", "max_redemptions": 20, "livemode": false}, "end": 1333254503, "start": 1330576103, "object": "discount", "id": "di_rIPvkhMQbnG7r9"}, "closed": true, "amount_due": 1000, "ending_balance": 1000, "period_end": 1330576104, "object": "invoice", "attempt_count": 0, "id": "in_2cWjoyxSbFRhmN", "livemode": false, "starting_balance": 0}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event)
          @invoiceitem = '{"livemode": false, "amount": 1000, "description": "Button Push Overage", "currency": "usd", "object": "invoiceitem", "date": 1330579859, "id": "ii_4F6W7lGsQv"'
          FakeWeb.register_uri(:post, "https://api.stripe.com/v1/invoiceitems" ,{body: @invoiceitem, status: ["200", "OK"]})
        end

        it "should reset the user's usage counter if there is no overage" do
          @user.use_unit
          @user.unit_usage.should == 1
          @processor.process(@event)
          @user.unit_usage.should == 0
        end

        it "should generate an invoiceitem and reset the user's usage counter if there is overage" do
          15.times { @user.use_unit }
          # No good way to check if an extra invoice item was created so we'll just put the same checks and figure if they still pass with extra code they are good
          @user.unit_usage.should == 15
          @processor.process(@event)
          @user.unit_usage.should == 0
        end
      end

      context "when an invoice is paid" do
        before :each do
          @subscription_plan = Factory(:subscription_plan, vault_token: 'plan-1', unit_name: 'Button Push', included_units: 10, overage_price: 10)
          @user = Factory(:user, vault_token: '123456', subscription_plan: @subscription_plan)
          @event = '{"livemode": false, "type": "invoice.payment_succeeded", "pending_webhooks": 0, "data": {"object": {"amount_due": 4140, "attempt_count": 0, "attempted": true, "closed": true, "customer": "123456", "ending_balance": 0, "livemode": false, "next_payment_attempt": null, "object": "invoice", "paid": true, "starting_balance": 0, "subtotal": 4600, "total": 4140, "discount": { "end": 1333401541, "id": "di_HJZlbeDqk9TQOk", "object": "discount", "start": 1330723141, "coupon": { "duration": "once", "id": "coupon-1", "livemode": false, "max_redemptions": 20, "object": "coupon", "percent_off": 10, "redeem_by": 1333238399, "times_redeemed": 2}}, "lines": {"invoiceitems": [{"date": 1330722230, "customer": "cus_hq8QQlFxQpqL4z", "description": "Button Push Overage", "object": "invoiceitem", "amount": 100, "id": "ii_l8lpmjYWVoZozw", "invoice": "in_cjnjIQaiVkPW2w", "currency": "usd", "livemode": false}], "subscriptions": [{ "amount": 4500, "plan": { "interval": "month", "object": "plan", "amount": 4500, "name": "Silver", "id": "silver", "livemode": false, "currency": "usd"}, "period": { "end": 1335988400, "start": 1333396400}}]}}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event)
        end

        it "should ask to send an invoice" do
          @processor.process(@event).should be_true
          Resque.size(:invoice_mailer).should == 1
        end
      end

      context "when an invoice fails" do
        before :each do
          @subscription_plan = Factory(:subscription_plan, vault_token: 'plan-1', unit_name: 'Button Push', included_units: 10, overage_price: 10)
          @user = Factory(:user, vault_token: '123456', subscription_plan: @subscription_plan)
          @event = '{"livemode": false, "type": "invoice.payment_failed", "pending_webhooks": 0, "data": {"object": {"amount_due": 4140, "attempt_count": 0, "attempted": true, "closed": true, "customer": "123456", "ending_balance": 0, "livemode": false, "next_payment_attempt": 1333401541, "object": "invoice", "paid": false, "starting_balance": 0, "subtotal": 4600, "total": 4140, "discount": { "end": 1333401541, "id": "di_HJZlbeDqk9TQOk", "object": "discount", "start": 1330723141, "coupon": { "duration": "once", "id": "coupon-1", "livemode": false, "max_redemptions": 20, "object": "coupon", "percent_off": 10, "redeem_by": 1333238399, "times_redeemed": 2}}, "lines": {"invoiceitems": [{"date": 1330722230, "customer": "cus_hq8QQlFxQpqL4z", "description": "Button Push Overage", "object": "invoiceitem", "amount": 100, "id": "ii_l8lpmjYWVoZozw", "invoice": "in_cjnjIQaiVkPW2w", "currency": "usd", "livemode": false}], "subscriptions": [{ "amount": 4500, "plan": { "interval": "month", "object": "plan", "amount": 4500, "name": "Silver", "id": "silver", "livemode": false, "currency": "usd"}, "period": { "end": 1335988400, "start": 1333396400}}]}}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event)
        end

        it "should ask to send an invoice" do
          @processor.process(@event).should be_true
          Resque.size(:invoice_mailer).should == 1
        end
      end

      context "when a subscription is canceled" do
        before :each do
          @subscription_plan = Factory(:subscription_plan, vault_token: 'plan-1', unit_name: 'Button Push', included_units: 10, overage_price: 10)
          @user = Factory(:user, vault_token: '123456', subscription_plan: @subscription_plan)
          @event = '{"livemode": false, "type": "customer.subscription.deleted", "pending_webhooks": 0, "data": {"object": {"status": "canceled", "canceled_at": 1330731595, "trial_start": 1328912763, "start": 1328912763, "trial_end": 1331504763, "customer": "123456", "object": "subscription", "current_period_start": 1328912763, "plan": {"interval": "month", "trial_period_days": 30, "object": "plan", "amount": 1000, "name": "Bronze", "id": "bronze", "currency": "usd", "livemode": false}, "current_period_end": 1331504763, "ended_at": 1330731595}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
          FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: @event)
        end

        it "should remove the subscription from the user" do
          @processor.process(@event)
          @user.reload
          @user.subscription_plan.should be_nil
        end
      end
    end

  end
end 