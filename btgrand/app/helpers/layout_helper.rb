module LayoutHelper
 
  def normal_room(number, size = 1, options = {})
    attr = {}
    if not @usedlist.index(number).nil?
      rtype = ' occupied'
    elsif not @needcheckout.index(number).nil?
      rtype = ' overcheckout'
    elsif not @checkout.index(number).nil?
      rtype = ' checkout'
    else
      rtype = ' normal_room'      
    end
    
    attr[:class] = 'grid_%d' % size
    attr = attr.merge(options)
    attr[:class] = attr[:class] + rtype
    attr[:id] = number    
    content_tag(:div, number, attr) if number
  end  
  
  def ladder
    content_tag(:div, 'บันได', :class => 'grid_1 ladder')
  end
  
  def f_empty_block(size)
    content_tag(:div, '&nbsp;', :class => 'grid_'+size.to_s+' f_empty')
  end
  
  def e_empty_block(size)
    content_tag(:div, '&nbsp;', :class => 'grid_'+size.to_s+' e_empty')
  end  
  
  def room_from_list(floor, list)
    for room in list do
        if room.class == Fixnum
          concat normal_room(floor*100 + room)
        else
          concat ladder
        end         
      end
  end
  
  def full_floor(floor)
    if floor == 1 
      firstfl = [9, 8, 7, 6, 5, 'บันได', 4, 3, 2, 1]  
      room_from_list floor, firstfl    
      
      room_from_list floor, [10, 11, 12, 14]
    elsif floor == 5
      concat f_empty_block(1)
      concat normal_room(509, 1, :class => 'grid_1 r509')
      concat normal_room(507, 2)
      concat normal_room(505)
      concat ladder
      concat normal_room(503, 2)
      concat normal_room(501)
      concat e_empty_block(1)        
      concat normal_room(508, 2)
      concat normal_room(506, 2)
      concat normal_room(504, 2)
      concat normal_room(502)
      concat e_empty_block(1)
    else  
      odd = [19, 17, 15, 11, 9, 'บันได', 7, 5, 3, 1]    
      room_from_list floor, odd
      
      10.times do |i|
        concat normal_room((floor*100)+(21-(2*i+1)))
      end
    end       
    
  end
end
