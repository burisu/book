# == Schema Information
# Schema version: 20090618212207
#
# Table name: questionnaires
#
#  id           :integer         not null, primary key
#  name         :string(64)      not null
#  intro        :text            
#  comment      :text            
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Questionnaire < ActiveRecord::Base
end
