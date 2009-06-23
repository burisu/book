# == Schema Information
# Schema version: 20090621154736
#
# Table name: questions
#
#  id               :integer         not null, primary key
#  name             :string(255)     not null
#  explanation      :text            
#  position         :integer         
#  questionnaire_id :integer         
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  lock_version     :integer         default(0), not null
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
