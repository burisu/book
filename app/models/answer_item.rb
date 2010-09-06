# == Schema Information
#
# Table name: answer_items
#
#  answer_id    :integer       not null
#  content      :text          
#  created_at   :datetime      
#  id           :integer       not null, primary key
#  lock_version :integer       default(0)
#  question_id  :integer       not null
#  updated_at   :datetime      
#

class AnswerItem < ActiveRecord::Base

  def validate
    if self.answer
      errors.add_to_base("Une réponse validée ne peut plus être modifiée.") if self.answer.locked?
    end
  end

end
