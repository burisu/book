# == Schema Information
# Schema version: 20090621154736
#
# Table name: zone_natures
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  parent_id    :integer         
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class ZoneNature < ActiveRecord::Base
end
