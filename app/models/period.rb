# == Schema Information
# Schema version: 20090404133338
#
# Table name: periods
#
#  id           :integer         not null, primary key
#  begun_on     :date            not null
#  finished_on  :date            not null
#  person_id    :integer         not null
#  folder_id    :integer         not null
#  comment      :text            
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#  family_name  :string(255)     not null
#  address      :string(255)     not null
#  country_id   :integer         
#  latitude     :float           
#  longitude    :float           
#  photo        :string(255)     
#  phone        :string(32)      
#  fax          :string(32)      
#  email        :string(32)      
#  mobile       :string(32)      
#

class Period < ActiveRecord::Base
  
  def validate
  end

  def before_validation
    self.person_id = self.folder.person_id   
  end

  def name
    self.family.title+' (du '+self.begun_on.to_s+' au '+self.finished_on.to_s+')'
  end

end
