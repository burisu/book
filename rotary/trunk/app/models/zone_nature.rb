# == Schema Information
#
# Table name: zone_natures
#
#  created_at   :datetime      not null
#  id           :integer       not null, primary key
#  lock_version :integer       default(0), not null
#  name         :string(255)   not null
#  parent_id    :integer       
#  updated_at   :datetime      not null
#

class ZoneNature < ActiveRecord::Base
  belongs_to :parent, :class_name=>ZoneNature.name
  has_many :zones, :foreign_key=>"nature_id"

end
