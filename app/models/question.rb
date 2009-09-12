# == Schema Information
#
# Table name: questions
#
#  created_at       :datetime      not null
#  explanation      :text          
#  id               :integer       not null, primary key
#  lock_version     :integer       default(0), not null
#  name             :string(255)   not null
#  position         :integer       
#  questionnaire_id :integer       
#  updated_at       :datetime      not null
#

class Question < ActiveRecord::Base
  acts_as_list :scope=>:questionnaire


  def duplicate(attributes={})
    question = self.class.new({:name=>self.name, :explanation=>self.explanation}.merge(attributes))
    question.save!
    question
  end

  def answer(person)
    "tot"
  end

end
