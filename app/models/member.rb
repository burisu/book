# == Schema Information
# Schema version: 20090529124009
#
# Table name: members
#
#  id           :integer         not null, primary key
#  last_name    :string(255)     not null
#  first_name   :string(255)     not null
#  photo        :string(255)     
#  nature       :string(8)       not null
#  other_nature :string(255)     
#  sex          :string(1)       not null
#  phone        :string(32)      
#  fax          :string(32)      
#  mobile       :string(32)      
#  comment      :text            
#  person_id    :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#  email        :string(255)     
#

class Member < ActiveRecord::Base

  def name
    self.first_name+' '+self.last_name
  end

end
