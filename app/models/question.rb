# == Schema Information
#
# Table name: questions
#
#  created_at       :datetime      
#  explanation      :text          
#  id               :integer       not null, primary key
#  lock_version     :integer       default(0)
#  name             :string(255)   not null
#  position         :integer       
#  questionnaire_id :integer       
#  theme_id         :integer       
#  updated_at       :datetime      
#

class Question < ActiveRecord::Base
  acts_as_list :scope=>:questionnaire
  validates_presence_of :theme_id

  def validate
    if self.questionnaire
      errors.add_to_base("Un questionnaire en ligne ne peut être modifié") if self.questionnaire.started_on<=Date.today and Date.today<=self.questionnaire.stopped_on
    end
  end

  def duplicate(attributes={})
    question = self.class.new({:name=>self.name, :explanation=>self.explanation, :theme_id=>self.theme_id}.merge(attributes))
    question.save!
    question
  end

  def answer(person)
    "tot"
  end

end
