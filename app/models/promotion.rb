# == Schema Information
# Schema version: 4
#
# Table name: promotions
#
#  id               :integer       not null, primary key
#  name             :string(255)   not null
#  is_outbound      :boolean       default(true), not null
#  comes_from_north :boolean       default(true), not null
#  created_at       :datetime      not null
#  updated_at       :datetime      not null
#  lock_version     :integer       default(0), not null
#

class Promotion < ActiveRecord::Base
end
