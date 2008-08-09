# == Schema Information
# Schema version: 20080808080808
#
# Table name: families
#
#  id           :integer         not null, primary key
#  title        :string(512)     not null
#  country_id   :integer         not null
#  name         :string(255)     not null
#  address      :string(255)     not null
#  latitude     :float           
#  longitude    :float           
#  comment      :text            
#  photo        :string(255)     
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Family < ActiveRecord::Base
end
