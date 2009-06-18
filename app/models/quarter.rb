# == Schema Information
# Schema version: 20090618212207
#
# Table name: quarters
#
#  id               :integer         not null, primary key
#  launched_on      :date            not null
#  questionnaire_id :integer         not null
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  lock_version     :integer         default(0), not null
#

class Quarter < ActiveRecord::Base
end
