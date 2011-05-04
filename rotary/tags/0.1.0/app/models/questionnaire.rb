# == Schema Information
#
# Table name: questionnaires
#
#  comment      :text          
#  created_at   :datetime      not null
#  id           :integer       not null, primary key
#  intro        :text          
#  lock_version :integer       default(0), not null
#  name         :string(64)    not null
#  promotion_id :integer       
#  started_on   :date          
#  stopped_on   :date          
#  updated_at   :datetime      not null
#

class Questionnaire < ActiveRecord::Base
  belongs_to :promotion
  has_many :answers
  has_many :questions, :dependent => :destroy
  validates_presence_of :started_on, :stopped_on, :promotion_id
  

  def before_validation
    self.name
    while self.class.find(:first, :conditions=>["name LIKE ? AND id!=?", self.name, self.id||0])
      self.name.succ!
    end
    self.started_on ||= Date.today-1
    self.stopped_on ||= self.started_on
  end

  def before_destroy
    self.questions.clear
  end

  def validate
    errors.add(:stopped_on, "doit être posterieure à la date de début") if self.started_on>self.stopped_on
    # errors.add_to_base("Un questionnaire en ligne ne peut être modifié") if self.started_on<=Date.today and Date.today<=self.stopped_on
  end


  def duplicate
    questionnaire = self.class.new
    questionnaire.name = ('Copie de '+self.name.to_s)[0..63]
    questionnaire.intro = self.intro
    if questionnaire.save
      for question in self.questions.find(:all, :order=>:position)
        question.duplicate(:questionnaire_id=>questionnaire.id)
      end
      return questionnaire
    else
      return nil
    end
  end

  def questions_size
    Question.count(:conditions=>{:questionnaire_id=>self.id})
  end

  def answers_size
    Answer.count(:conditions=>{:questionnaire_id=>self.id, :ready=>true})
  end

  def active(active_on=Date.today)
    b = self.started_on||(active_on+1)
    e = self.stopped_on||(active_on+1)
    b <= active_on and active_on <= e
  end

  def promotion_name
    self.promotion ? self.promotion.name : ""
  end

  def state_for(person)
    answers = Answer.find_all_by_questionnaire_id_and_person_id(self.id, person.id)
    if answers.size == 0
      :empty
    elsif answers.size == 1
      if answers[0].locked or answers[0].ready
        :locked
      else
        :editable
      end
    else
      :error
    end
  end

end
