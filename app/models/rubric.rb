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
# == Table: rubrics
#
#  code          :string(255)      not null
#  created_at    :datetime         not null
#  description   :text             
#  id            :integer          not null, primary key
#  lock_version  :integer          default(0), not null
#  logo          :string(255)      
#  name          :string(255)      not null
#  parent_id     :integer          
#  rubrics_count :integer          default(0), not null
#  updated_at    :datetime         not null
#

# encoding: utf-8
class Rubric < ActiveRecord::Base
  belongs_to :parent, :class_name=>Rubric.name
  has_many :articles
  validates_uniqueness_of :code

  before_validation do
    self.code = self.name if self.code.blank?
    self.code = self.code.to_s.parameterize
  end

  def to_param
    self.code
  end
end
