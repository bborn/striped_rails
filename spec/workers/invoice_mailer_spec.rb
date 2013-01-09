require 'spec_helper'
require 'fakeweb'


module StripedRails
    describe InvoiceMailer do
      it "should email a thank you invoice with successful payment" do
        subscription_plan = Factory(:subscription_plan, vault_token: 'plan-1', unit_name: 'Button Push', included_units: 10, overage_price: 10)
        user = Factory(:user, vault_token: '123456', subscription_plan: subscription_plan)
        event = '{"livemode": false, "type": "invoice.payment_succeeded", "pending_webhooks": 0, "data": {"object": {"amount_due": 4140, "attempt_count": 0, "attempted": true, "closed": true, "customer": "123456", "ending_balance": 0, "livemode": false, "next_payment_attempt": null, "object": "invoice", "paid": true, "starting_balance": 0, "subtotal": 4600, "total": 4140, "discount": { "end": 1333401541, "id": "di_HJZlbeDqk9TQOk", "object": "discount", "start": 1330723141, "coupon": { "duration": "once", "id": "coupon-1", "livemode": false, "max_redemptions": 20, "object": "coupon", "percent_off": 10, "redeem_by": 1333238399, "times_redeemed": 2}}, "lines": {"invoiceitems": [{"date": 1330722230, "customer": "cus_hq8QQlFxQpqL4z", "description": "Button Push Overage", "object": "invoiceitem", "amount": 100, "id": "ii_l8lpmjYWVoZozw", "invoice": "in_cjnjIQaiVkPW2w", "currency": "usd", "livemode": false}], "subscriptions": [{ "amount": 4500, "plan": { "interval": "month", "object": "plan", "amount": 4500, "name": "Silver", "id": "silver", "livemode": false, "currency": "usd"}, "period": { "end": 1335988400, "start": 1333396400}}]}}}, "object": "event", "id": "evt_9l7Jwf4Ei7upQ5", "created": 1328912764}'
        FakeWeb.register_uri(:get, "https://api.stripe.com/v1/events/evt_9l7Jwf4Ei7upQ5", body: event)
        invoice = Stripe::Event.retrieve('evt_9l7Jwf4Ei7upQ5').data.object
        InvoiceMailer.perform(user.id, invoice.to_json)
        mail = ActionMailer::Base.deliveries.last
        body = mail.body.parts.find { |p| p.content_type.match '/plain' }.body.raw_source
        body.should include "Thank you"
        body.should include "$45.00"
        body.should include "$1.00"
        body.should include "$46.00"
        body.should include "$41.40"
        body.should include "10%"
      end
    end
end