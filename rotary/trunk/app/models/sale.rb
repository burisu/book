# == Schema Information
#
# Table name: sales
#
#  amount       :decimal(16, 2 
#  client_email :string(255)   not null
#  client_id    :integer       
#  comment      :text          
#  created_at   :datetime      
#  created_on   :date          not null
#  id           :integer       not null, primary key
#  lock_version :integer       default(0)
#  number       :string(255)   not null
#  payment_id   :integer       
#  state        :string(255)   not null
#  updated_at   :datetime      
#

class Sale < ActiveRecord::Base
end
