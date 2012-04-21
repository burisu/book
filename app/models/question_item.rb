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
# == Table: question_items
#
#  created_at   :datetime         not null
#  explanation  :text             
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  name         :string(255)      not null
#  position     :integer          
#  question_id  :integer          
#  theme_id     :integer          
#  updated_at   :datetime         not null
#

# encoding: utf-8
class QuestionItem < ActiveRecord::Base
  acts_as_list :scope=>:question
  belongs_to :question
  belongs_to :theme
  has_many :answer_items
  validates_presence_of :theme_id

  validate do
    if self.question
      errors.add_to_base("Un questionnaire en ligne ne peut être modifié") if self.question.started_on<=Date.today and Date.today<=self.question.stopped_on
    end
  end

  def duplicate(attributes={})
    item = self.class.new({:name=>self.name, :explanation=>self.explanation, :theme_id=>self.theme_id}.merge(attributes))
    item.save!
    item
  end

  def answer(person)
    "tot"
  end

end
