# == Schema Information
# Schema version: 20090621154736
#
# Table name: answer_items
#
#  id           :integer         not null, primary key
#  content      :text            
#  answer_id    :integer         not null
#  question_id  :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class AnswerItem < ActiveRecord::Base

  def validate
    if self.answer
      errors.add_to_base("Une réponse validée ne peut plus être modifiée.") if self.answer.locked?
    end
  end

end
