# == Schema Information
# Schema version: 2
#
# Table name: mandate_natures
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  code         :string(4)       not null
#  parent_id    :integer         
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class MandateNature < ActiveRecord::Base
end
