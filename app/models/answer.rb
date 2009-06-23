# == Schema Information
# Schema version: 20090621154736
#
# Table name: answers
#
#  id               :integer         not null, primary key
#  created_on       :date            
#  ready            :boolean         not null
#  locked           :boolean         not null
#  person_id        :integer         not null
#  questionnaire_id :integer         not null
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  lock_version     :integer         default(0), not null
#

class Answer < ActiveRecord::Base
  validates_uniqueness_of :person_id, :scope=>:questionnaire_id
  def before_validation
    self.created_on ||= Date.today
  end

  

end
