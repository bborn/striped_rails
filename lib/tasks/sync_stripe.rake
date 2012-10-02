namespace :stripe do
  desc 'Sync the information on plans and coupons from Stripe.'
  task sync: :environment do
    StripedRails::SubscriptionPlan.update_stripe_plans
    StripedRails::Coupon.update_stripe_coupons
  end
end