module DetailHelper
  def pay_list(paylists)
    result = '<ol>'
    paylists.each do |pay|
      payed = pay.ispay ? " payed" : ""
      result += '<li class="paylist'+payed+'"><span class="pdetail">'+pay.detail+'</span><span class="price">'+('%d' % pay.price)+'</span></li>'
    end
    result += '</ol>'
  end
  
  def price_sumary(transac)
    paysum = 0
    unpaysum = 0
    for pay in transac.paylist do
      if pay.ispay?
        paysum += pay.price 
      end
      unpaysum += pay.price 
    end
  
    bal = (paysum - unpaysum) + transac.balance
    
    result = '<div class="block">มัดจำ : <b '+get_color(transac.deposit)+' >%d</b> </div>' % transac.deposit
    result +=  '<div class="block">บัญชี : <b '+get_color(transac.balance)+'>%d</b> </div>' % transac.balance
    result +=  '<div class="block">ยอดค้าง : <b '+get_color(bal)+' >%d</b> </div>' % (bal if bal < 0)
  end
  
  def payment_form(transac)
    count = 0
    result = 'เลือกจากรายการ <br /><hr size="1">'    
    transac.paylist.each do |pay|
      if !pay.ispay?
        count += 1
        result += check_box_tag 'payment['+pay.id.to_s+']', pay.ispay
        result += '&nbsp;<span class="pdetail">'+pay.detail+'</span><span class="price">'+('%d' % pay.price)+'</span><br />'
      end      
    end
    result += '<hr size="1">หรือป้อนจำนวนเงิน  <input type="text" id="deposit" name="deposit" size="4" maxlength="4" class="num_text_box" ><br />'
    result += '<center><input type="submit" value="ทำรายการ" class="ui-state-default ui-corner-all" id="payment_submit"></center>'
    if count == 0
      result = '<center><br /><br /><br /><br />ไม่มียอดค้างชำระ</center>'
    end
    return result
  end  
  
private 
  def get_color(num)
    if num > 0
      return 'style="color: green;"'
    elsif num < 0
      return 'style="color: red;"'
    else
      return ''
    end
  end
end