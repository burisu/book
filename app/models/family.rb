# == Schema Information
# Schema version: 2
#
# Table name: families
#
#  id           :integer         not null, primary key
#  code         :integer         not null
#  comment      :text            
#  photo        :string(255)     
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Family < ActiveRecord::Base
end
