# == Schema Information
# Schema version: 20090621154736
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
#  started_on   :date            
#  stopped_on   :date            
#

class Questionnaire < ActiveRecord::Base
  has_many :questions, :dependent => :destroy
  validates_presence_of :started_on, :stopped_on

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
    errors.add_to_base("Un questionnaire en ligne ne peut être modifié") if self.started_on<=Date.today and Date.today<=self.stopped_on
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

  def self.of(person)
    Questionnaire.find(:all, :conditions=>["id IN (SELECT questionnaire_id FROM answers WHERE person_id=?) OR CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE+'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE+'1 day'::INTERVAL)", person.id])
  end

  def state_for(person)
    answers = Answer.find_all_by_questionnaire_id_and_person_id(self.id, person.id)
    if answers.size == 0
      :empty
    elsif answers.size == 1
      if answers[0].locked
        :locked
      else
        :editable
      end
    else
      :error
    end
  end

end
