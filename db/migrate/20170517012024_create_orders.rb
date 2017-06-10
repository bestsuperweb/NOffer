class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :ordername
      t.references :shop, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :orders, [:shop_id, :created_at]
  end
end
