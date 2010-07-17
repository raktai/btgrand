class CreatePaylists < ActiveRecord::Migration
  def self.up
    create_table  :paylists do |t|
      t.column    :transac_id, :integer
      t.string    :detail
      t.column    :ptype, :integer # 0 - normal, 1 - room 
      t.column    :price, :decimal, :precision => 8, :scale => 2, :default => 0
      t.column    :room_price_date, :datetime
      t.column    :ispay, :boolean
      t.column    :iscancel, :boolean
      t.column    :user_id, :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :paylists
  end
end
