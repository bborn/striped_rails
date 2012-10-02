class CreatePages < ActiveRecord::Migration
  def change
    create_table :striped_rails_pages do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.integer :menu_order

      t.timestamps
    end
    add_index :striped_rails_pages, :slug, :unique => true
    add_index :striped_rails_pages, :menu_order
  end
end
