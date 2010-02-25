# == Schema Information
#
# Table name: answers
#
#  created_at       :datetime      not null
#  created_on       :date          
#  id               :integer       not null, primary key
#  lock_version     :integer       default(0), not null
#  locked           :boolean       not null
#  person_id        :integer       not null
#  questionnaire_id :integer       not null
#  ready            :boolean       not null
#  updated_at       :datetime      not null
#

class Answer < ActiveRecord::Base
  validates_uniqueness_of :person_id, :scope=>:questionnaire_id
  has_many :items, :class_name=>AnswerItem.name, :dependent=>:destroy

  def before_validation
    self.created_on ||= Date.today
  end

  def validate_on_update
    ans = Answer.find_by_id(self.id)
    errors.add_to_base("Une réponse validée ne peut plus être modifiée.") if ans.locked?
  end

  def status
    if self.locked
      "locked"
    elsif self.ready
      "ready"
    else
      "writing"
    end
  end

end
