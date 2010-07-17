class Transac < ActiveRecord::Base  
  has_many :paylist, :order => 'created_at'
  
  attr_accessor :days
  attr_accessor :sum
  attr_accessor :pay
  
  validates_presence_of(:room_no, :message => "กรุณาใส่หมายเลขห้อง")
  validates_presence_of(:days, :message => "กรุณาใส่จำนวนวัน")  
  validates_presence_of(:customer_name, :message => "กรุณาใส่ชื่อ - นามสกุล")
  validates_numericality_of(:days, :message => "กรุณาป้อนตัวเลข")
  validates_numericality_of(:price, :message => "กรุณาป้อนตัวเลข")
  validates_numericality_of(:pay, :message => "กรุณาป้อนตัวเลข")
  validates_numericality_of(:deposit, :message => "กรุณาป้อนตัวเลข")
  validate :check_blocked_room
  validate :price_must_more_than_zero
  validate :pay_must_more_than_zero
  validate :days_must_more_than_zero
  
  def self.UsedRoom(idate)    
    self.find(:all, :conditions => ["date(checkout) > ? AND isactive = 1", idate])
  end  
  
  def self.CheckOut(idate)    
    self.find(:all, :conditions => ["date(checkout) = ? AND isactive = 1", idate])
  end
  
  def self.NeedCheckOut(idate)    
    self.find(:all, :conditions => ["checkout < ? AND isactive = 1", idate])
  end
  
  def self.DetailRoom(roomno)
    self.find(:all, :conditions => ["room_no = ? AND isactive = 1", roomno])
  end
  
  def self.AllUsedRoom
    self.find(:all, :conditions => ["isactive = 1"], :order => "room_no")
  end
  
  HUMANIZED_ATTRIBUTES = {
    :room_no=> "ห้อง",
    :days=>"วัน",
    :customer_name=>"ชื่อ - นามสกุล",
    :price => "ราคา",
    :deposit => "มัดจำ",
    :pay => "รายรับ"
  }

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
protected
  def check_blocked_room
#    blockedrooms = Blockedroom.find(:all)  
    list = []
#    blockedrooms.each do |room|
#      list.push(room.room_no)
#    end  
    
    Transac.AllUsedRoom.each do |room|
      list.push(room.room_no)
    end
    
    if not list.index(room_no).nil? 
      errors.add(:room_no, "ห้องนี้ไม่สามารถขายได้ กรุณาเลือกห้องใหม่")
    end
  end
  
  def price_must_more_than_zero
    errors.add(:price, "กรุณาป้อนตัวเลขมากกว่า 0") if price.nil? || price.to_i <= 0
  end
  
  def pay_must_more_than_zero
    errors.add(:pay, "กรุณาป้อนตัวเลขมากกว่า 0") if pay.nil? || pay.to_i < 0
  end
  
  def days_must_more_than_zero
    errors.add(:days, "กรุณาป้อนตัวเลขมากกว่า 0") if days.nil? || days.to_i <= 0
  end
  
  def days_before_type_cast
    days
  end
  
  def sum_before_type_cast
    sum
  end
  
  def pay_before_type_cast
    pay
  end
end
