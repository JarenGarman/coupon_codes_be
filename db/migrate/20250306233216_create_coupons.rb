class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code
      t.string :discount_type
      t.float :value
      t.boolean :active

      t.timestamps
    end
    add_index :coupons, :code, unique: true
  end
end
