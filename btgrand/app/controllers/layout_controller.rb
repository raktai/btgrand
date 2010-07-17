class LayoutController < ApplicationController
  layout "main"
  
	def index
		@title = "BT Grand Condotel"
    @date = get_date(params[:date])
    
    @detail = {}   
    
    needcheckout = Transac.NeedCheckOut(Time.now)
    @needcheckout = []
    needcheckout.each do |room|
      @needcheckout.push(room.room_no)
      @detail[room.room_no] = room
    end

    checkout = Transac.CheckOut(@date)
    @checkout = []
    checkout.each do |room|
      @checkout.push(room.room_no)
      @detail[room.room_no] = room
    end
    
    usedrooms = Transac.UsedRoom(@date)
    @usedlist = []
    usedrooms.each do |room|
      @usedlist.push(room.room_no)
      @detail[room.room_no] = room
    end
   
    
	end
  
  def new       
    roomno = params[:room_no].to_i
    if all_room.index(roomno).nil?
        redirect_to(:action => "index")      
    end
    @title = "เช็คอิน"
    @transac = Transac.new    
    
    ##########################
    list = []
#    blockedrooms = Blockedroom.find(:all)    
#    @list = []
#    blockedrooms.each do |room|
#      @list.push(room.list)
#    end  
    
    Transac.AllUsedRoom.each do |room|
      list.push(room.room_no)
    end
        
    @transac.room_no = roomno          
    if not list.index(roomno).nil? 
      @transac.errors.add(:room_no, "ห้องนี้ไม่สามารถขายได้ กรุณาเลือกห้องใหม่")      
    end
    ##########################
  end

  def checkin
    @title = "เช็คอิน"
    @transac = Transac.new(params[:transac])
    timenow = Time.now
    @transac.checkin = timenow
    checkout = timenow.advance(:days => @transac.days.to_i)
    @transac.checkout = DateTime.new(checkout.year, checkout.month, checkout.day, 13, 0)
    @transac.isactive = 1
    bal = @transac.pay.to_i
    
    @transac.days.to_i.times do |i|
      @transac.paylist.build({:detail => "ค่าห้อง "+(@transac.checkin.advance(:days => i)).strftime('%d/%m/%Y'), 
                              :price => @transac.price, 
                              :ispay => (bal >= @transac.price),
                              :room_price_date => Date.parse(@transac.checkin.advance(:days => i).strftime('%Y/%m/%d')),
                              :ptype => 1})      
      bal -= @transac.price unless bal < @transac.price
    end

    @transac.balance = bal    
    

    respond_to do |format|
      if @transac.save        
        format.html { redirect_to(:action => "index") }
      else
        format.html { render :action => "new" }        
      end
    end
  end
  
  def detail    
    @transac = Transac.DetailRoom(params[:room_no])[0]
    @title = 'รายละเอียดห้อง : '+@transac.room_no.to_s unless @transac.nil?
    @history = get_room_history(@transac.id) unless @transac.nil?
#    @freeroom = get_free_room
#    @history = get_room_history(@transac.id)        
    
    if all_room.index(params[:room_no].to_i).nil?
      redirect_to(:action => "index")      
    elsif @transac.nil?
      redirect_to(:action => "new", :room_no => params[:room_no])              
    end    
  end
  
  def payment
    @transac = Transac.DetailRoom(params[:roomno])[0]     
    respond_to do |format|      
      format.js      
    end
  end
  
  def expandday
    @transac = Transac.DetailRoom(params[:roomno])[0]     
    respond_to do |format|      
      format.js      
    end
  end
  
  def doexpand
    Transac.transaction do
      @transac = Transac.find(params[:transacid].to_i)
      if !@transac.nil?
        days = params[:days].to_i
        if days > 0
          ispay = @transac.balance >= @transac.price
          checkout = @transac.checkout.advance(:days => days)   
          @transac.paylist.build({:detail => "ค่าห้อง "+checkout.strftime('%d/%m/%Y'),
                                  :price => @transac.price*days,
                                  :room_price_date => Date.parse(checkout.strftime('%Y/%m/%d')),
                                  :ispay => ispay,
                                  :ptype => 1})                
          @transac.update_attribute(:checkout, checkout)             
          @transac.update_attribute(:balance, @transac.balance - @transac.price) if ispay
        end          
      end
    end
    
    respond_to do |format|                          
        format.js 
    end
  end
  
  def dopay
    Paylist.transaction do
      if !params[:payment].nil?
        params[:payment].each do |pay|
          if !pay[1].nil?
            pl = Paylist.find(pay[0])
            pl.update_attribute(:ispay, true)
          end
        end
      end
    end
    
    #additional pay
    if !params[:deposit].nil?
      Transac.transaction do
        Paylist.transaction do
          balance = params[:deposit].to_i
          @transac = Transac.find(params[:transacid].to_i)
          if balance > 0            
            
            balance += @transac.balance
            for pay in @transac.paylist do
              if !pay.ispay? && balance >= pay.price
                balance -= pay.price
                pay.update_attribute(:ispay, true)
              end
            end
                        
            @transac.update_attribute(:balance, balance)
          end  
        end        
      end      
    end
    
    respond_to do |format|                          
        format.js 
    end
  end
  
  def changeremark
    @transac = Transac.find(params[:transacid])
    @transac.update_attribute(:remark, params[:remark])
    
    respond_to do |format|                          
        format.js 
    end
  end

  def checkout_form
    @transac = Transac.DetailRoom(params[:roomno])[0] 
    unpay = 0
    payed = 0
    for pay in @transac.paylist do
      if pay.ispay?
        payed += pay.price
      end
      if pay.ptype==1 and pay.room_price_date <= Date.today     
        unpay += pay.price
      elsif pay.ptype!=1
        unpay += pay.price
      end       
    end

    @bal = (payed - unpay) + @transac.balance
    respond_to do |format|
      format.js
    end
  end
  
  def checkout
    @transac = Transac.find(params[:transacid])
    #ให้เช็คเรื่องจ่ายเงินว่าคีย์เข้ามาเท่าไหร่ พอก้บที่ค้างไว้หรือไม่ ถ้าไม่พอไม่ยอมให้เช็คเอาต์
    unpaysum = 0
    payedsum = 0
    today = Date.today
    for pay in @transac.paylist do
      if pay.ispay?
        payedsum += pay.price
      end
      if pay.ptype == 1 and pay.room_price_date <= today     
        unpaysum += pay.price
      elsif pay.ptype!=1
        unpaysum += pay.price
      end 
    end
      
    bal = (payedsum - unpaysum) + @transac.deposit + @transac.balance
    
    if bal<0 && (params[:pay_checkout].nil? || (params[:pay_checkout].to_i + bal < 0))
      @error = "กรุณาใส่จำนวนเงินให้ตรงกับจำนวนต้องชำระเพิ่ม"
    else
      begin
        Transac.transaction do
          Paylist.transaction do
            for pay in @transac.paylist do
              if pay.ptype == 1 and pay.room_price_date > today     
                Paylist.delete(pay.id)
              elsif !pay.ispay?
                pay.update_attribute(:ispay,true)
              end
            end
            if @error.nil? &&  @transac.update_attribute(:isactive, false)
              @error = nil
            else
              if @error.nil?
                @error = "Checkout error! please check!!!"
              end
            end
          end
        end
      rescue ActiveRecord::RecordInvalid => invalid
        @error = "Checkout error! please check!!!"
      end
    end
    respond_to do |format|                          
        format.js
    end
  end

  def move_form
    @transac = Transac.DetailRoom(params[:roomno])[0]    
    @freeroom = get_free_room
    respond_to do |format|      
      format.js      
    end
  end
  
  def move 
    if !params[:changeroom].nil?
      Transac.transaction do
        old = Transac.find(params[:transacid].to_i)
        new = old.clone
        new.isactive = false
        new.save_with_validation(false)
        old.room_hist_id = new.id
        old.room_no = params[:chooseroom]
        old.save_with_validation(false)
      end
    end
    @transac = Transac.DetailRoom(params[:chooseroom])[0]    
    @title = 'รายละเอียดห้อง : '+@transac.room_no.to_s unless @transac.nil?
    @history = get_room_history(@transac.id)
    
    respond_to do |format|                          
      format.js
    end
  end
  
  def cancel_form
    @transac = Transac.DetailRoom(params[:roomno])[0]    
    respond_to do |format|      
      format.js      
    end
  end
  
  def cancel
    @transac = Transac.find(params[:transacid])
    if params[:remark].empty?
      @error = "กรุณาป้อนเหตุผลที่ยกเลิก"
    else
      @transac.remark = params[:remark]
      @transac.isactive = false
      @transac.iscancel = true
      if !@transac.save_with_validation(false)
        @error = "ERROR PLEASE CHECK!"
      end
    end
    respond_to do |format|                          
        format.js
    end
  end
  
private
  def get_date(date_s)
    begin
        d = Date.strptime(date_s, '%d%m%Y')
        if d < Date.today
          d = Date.today
        end
        return d
    rescue 
        return d = Date.today
    end
  end
  
  def get_free_room
    usedrooms = Transac.AllUsedRoom
    usedlist = []
    usedrooms.each do |room|
      usedlist.push(room.room_no.to_i)      
    end
    return all_room - usedlist
  end
  
  def get_room_history(tid)
    trans = Transac.find(tid)
    if trans.room_hist_id.nil?
      return nil
    else
      list = []
      while !trans.room_hist_id.nil?        
        trans = Transac.find(trans.room_hist_id)
        list.push(trans.clone)
      end
      return list
    end
  end
  
  def all_room
    allroom = [101,102,103,104,105,106,107,108,109,110,111,112,114,
               201,202,203,204,205,206,207,208,209,210,211,212,214,
               215,216,217,218,219,220,301,302,303,304,305,306,307,
               308,309,310,311,312,314,315,316,317,318,319,320,401,
               402,403,404,405,406,407,408,409,410,411,412,414,415,
               416,417,418,419,420,501,502,503,504,505,506,507,508,509]     
    return allroom
  end
end