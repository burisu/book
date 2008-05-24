# == Schema Information
# Schema version: 4
#
# Table name: roles
#
#  id                :integer       not null, primary key
#  name              :string(255)   not null
#  restriction_level :integer       default(1000), not null
#  created_at        :datetime      not null
#  updated_at        :datetime      not null
#  lock_version      :integer       default(0), not null
#

class Role < ActiveRecord::Base

  def self.find_or_create(name)
    r = Role.find_by_name(name)
    r = Role.create(:name=>name, :restriction_level=>1000) if r.nil?
    r
  end
  
end
