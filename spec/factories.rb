FactoryGirl.define do
  factory :page do |p|
    p.sequence(:title) {|n| "Page #{n}"}
    p.sequence(:menu_order) {|n| "#{n}"}
    p.sequence(:content) {|n| "Page #{n}"}
  end

  factory :subscription_plan do |p|
    p.sequence(:vault_token) {|n| "plan-#{n}"}
    p.sequence(:name) {|n| "Plan #{n}"}
    currency "usd"
    interval "month"
    p.sequence(:amount) {|n| n*100}
    p.sequence(:trial_period_days) {|n| n*10}
  end

  factory :user do |u|
    u.sequence(:email) {|n| "user#{n}@test.com"}
    u.sequence(:full_name) {|n| "User #{n}"}
    is_admin false
    password '1234'
    password_confirmation '1234'
  end

  factory :coupon do |c|
    c.sequence(:coupon_code) {|n| "code-#{n}"}
    percent_off 10
    duration 'once'
  end
end