# == Schema Information
# Schema version: 20090404153612
#
# Table name: promotions
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  is_outbound  :boolean         default(TRUE), not null
#  from_code    :string(255)     default("N"), not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Promotion < ActiveRecord::Base
end
