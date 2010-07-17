class CreateTransacs < ActiveRecord::Migration
  def self.up
    create_table :transacs do |t|
      t.column :room_no, :integer
      t.column :checkin, :datetime
      t.column :checkout, :datetime
      t.column :customer_id, :integer
      t.string :customer_name
      t.string :customer_phone
      t.column :isactive, :boolean
      t.column :iscancel, :boolean
      t.column :room_hist_id, :integer
      t.string :remark
      t.column :deposit, :decimal, :precision => 8, :scale => 2, :default => 0
      t.column :price, :decimal, :precision => 8, :scale => 2, :default => 0
      t.column :balance, :decimal, :precision => 8, :scale => 2, :default => 0
      t.column :user_id, :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :transacs
  end
end
