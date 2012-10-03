# This migration comes from striped_rails (originally 20120228044200)
class CreateCouponSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :striped_rails_coupon_subscription_plans do |t|
      t.references :coupon
      t.references :subscription_plan

      t.timestamps
    end
    add_index :striped_rails_coupon_subscription_plans, :coupon_id, :name => 'by_cp_sub_plan_cp_id'
    add_index :striped_rails_coupon_subscription_plans, :subscription_plan_id, :name => 'by_cp_sub_plan_sub_plan_id'
  end
end
