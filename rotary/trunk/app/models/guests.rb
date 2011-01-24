# == Schema Information
#
# Table name: guests
#
#  annotation   :text          
#  created_at   :datetime      
#  email        :string(255)   
#  first_name   :string(255)   
#  id           :integer       not null, primary key
#  last_name    :string(255)   
#  lock_version :integer       default(0)
#  product_id   :integer       
#  sale_id      :integer       
#  sale_line_id :integer       
#  updated_at   :datetime      
#  zone_id      :integer       
#

class Guests < ActiveRecord::Base
end
