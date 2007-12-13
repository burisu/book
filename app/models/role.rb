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
end
