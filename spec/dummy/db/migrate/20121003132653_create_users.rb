class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email,              :null => false, :default => ""      
      
      t.string :full_name
      t.string :vault_token
      t.references :subscription_plan
      t.references :coupon
      t.boolean :admin, default: false

    end
  end

end
