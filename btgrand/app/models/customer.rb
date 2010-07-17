class Customer < ActiveRecord::Base
  validates_presence_of(:name, :message => "กรุณาป้อนชื่อ")
  validates_presence_of(:phone, :message => "กรุณาป้อนเบอร์โทรศัพท์")
  validates_numericality_of(:last_price, :message => "กรุณาป้อนตัวเลข")  
  validate :price_must_more_than_zero
  
  def self.search(search)   
      Customer.find :all, 
                    :conditions => [
                    'name LIKE ? OR sname LIKE ? OR nickname LIKE ? OR address_home LIKE ? OR address_work LIKE ?', 
                    "%#{search}%",
                    "%#{search}%",
                    "%#{search}%",                    
                    "%#{search}%",
                    "%#{search}%"
                    ], :order => "name"
  end  
  

  HUMANIZED_ATTRIBUTES = {
    :name=> "ชื่อ",
    :last_price => "ราคา",
    :phone => "โทรศัพท์"
  }

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

protected
  def price_must_more_than_zero
    errors.add(:last_price, "กรุณาป้อนตัวเลขมากกว่า 0") if last_price.nil? || last_price <= 0
  end


end
