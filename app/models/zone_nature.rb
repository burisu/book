# == Schema Information
#
# Table name: zone_natures
#
#  created_at   :datetime      
#  id           :integer       not null, primary key
#  lock_version :integer       default(0)
#  name         :string(255)   not null
#  parent_id    :integer       
#  updated_at   :datetime      
#

class ZoneNature < ActiveRecord::Base
end
