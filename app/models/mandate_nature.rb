# == Schema Information
# Schema version: 20090529124009
#
# Table name: mandate_natures
#
#  id             :integer         not null, primary key
#  name           :string(255)     not null
#  code           :string(8)       not null
#  zone_nature_id :integer         
#  parent_id      :integer         
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  lock_version   :integer         default(0), not null
#  rights         :text            
#

class MandateNature < ActiveRecord::Base
end
