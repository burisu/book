# encoding: utf-8
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
#  created_at       :datetime         not null
#  explanation      :text             
#  id               :integer          not null, primary key
#  lock_version     :integer          default(0), not null
#  name             :string(255)      not null
#  position         :integer          
#  questionnaire_id :integer          
#  theme_id         :integer          
#  updated_at       :datetime         not null
#

# encoding: utf-8
class Question < ActiveRecord::Base
  acts_as_list :scope=>:questionnaire
  belongs_to :questionnaire
  belongs_to :theme
  has_many :answer_items
  validates_presence_of :theme_id

  validate do
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
