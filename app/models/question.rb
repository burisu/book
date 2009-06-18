# == Schema Information
# Schema version: 20090618212207
#
# Table name: questions
#
#  id               :integer         not null, primary key
#  name             :string(255)     not null
#  explaning        :text            
#  position         :integer         
#  questionnaire_id :integer         
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  lock_version     :integer         default(0), not null
#

class Question < ActiveRecord::Base
end
