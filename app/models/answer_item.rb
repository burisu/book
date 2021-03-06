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
# == Table: answer_items
#
#  answer_id        :integer          not null
#  content          :text             
#  created_at       :datetime         not null
#  id               :integer          not null, primary key
#  lock_version     :integer          default(0), not null
#  question_item_id :integer          not null
#  updated_at       :datetime         not null
#

# coding: utf-8
class AnswerItem < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_presence_of :answer, :question_item
  #]VALIDATORS]
  belongs_to :answer
  belongs_to :question_item
  depends_on :answer

  validate do
    if self.answer
      errors.add_to_base("Une réponse validée ne peut plus être modifiée.") if self.answer.locked?
    end
  end

end
