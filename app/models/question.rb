# -*- coding: utf-8 -*-
# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2012 Brice Texier, Thibaud Merigon
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
# 
# == Table: questions
#
#  comment      :text             
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  intro        :text             
#  lock_version :integer          default(0), not null
#  name         :string(64)       not null
#  promotion_id :integer          
#  started_on   :date             
#  stopped_on   :date             
#  updated_at   :datetime         not null
#

# coding: utf-8
class Question < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_length_of :name, :allow_nil => true, :maximum => 64
  validates_presence_of :name
  #]VALIDATORS]
  belongs_to :promotion
  has_many :answers
  has_many :items, :class_name=>"QuestionItem", :dependent => :destroy, :order=>:position
  validates_presence_of :started_on, :stopped_on, :promotion_id
  

  before_validation do
    self.name
    while self.class.find(:first, :conditions=>["name LIKE ? AND id!=?", self.name, self.id||0])
      self.name.succ!
    end
    self.started_on ||= Date.today-1
    self.stopped_on ||= self.started_on
  end

  before_destroy do
    self.items.clear
  end

  validate do
    errors.add(:stopped_on, "doit être posterieure à la date de début") if self.started_on>self.stopped_on
    # errors.add_to_base("Un question en ligne ne peut être modifié") if self.started_on<=Date.today and Date.today<=self.stopped_on
  end


  def duplicate
    question = self.class.new
    question.name = ('Copie de '+self.name.to_s)[0..63]
    question.intro = self.intro
    if question.save
      for question in self.items.find(:all, :order=>:position)
        question.duplicate(:question_id=>question.id)
      end
      return question
    else
      return nil
    end
  end

  def items_size
    QuestionItem.count(:conditions=>{:question_id=>self.id})
  end

  def answers_size
    Answer.count(:conditions=>{:question_id=>self.id, :ready=>true})
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
    answers = Answer.find_all_by_question_id_and_person_id(self.id, person.id)
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
