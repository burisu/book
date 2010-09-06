# == Schema Information
#
# Table name: members
#
#  comment      :text          
#  created_at   :datetime      
#  email        :string(255)   
#  fax          :string(32)    
#  first_name   :string(255)   not null
#  id           :integer       not null, primary key
#  last_name    :string(255)   not null
#  lock_version :integer       default(0)
#  mobile       :string(32)    
#  nature       :string(8)     not null
#  other_nature :string(255)   
#  person_id    :integer       not null
#  phone        :string(32)    
#  photo        :string(255)   
#  sex          :string(1)     not null
#  updated_at   :datetime      
#

class Member < ActiveRecord::Base

  def name
    self.first_name+' '+self.last_name
  end

end
