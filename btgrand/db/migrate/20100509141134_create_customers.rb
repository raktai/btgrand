class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string    :identity_number
      t.string    :name
      t.string    :sname
      t.string    :nickname
      t.string    :company
      t.string    :address_home
      t.string    :address_work
      t.string    :phone
      t.string    :phone_work
      t.string    :picture
      t.string    :remark
      t.string    :vehicle
      t.column    :last_price, :decimal, :precision => 8, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
