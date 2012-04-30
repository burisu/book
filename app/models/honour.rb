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
# == Table: honours
#
#  abbreviation :string(255)      
#  code         :string(255)      
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  name         :string(255)      
#  nature_id    :integer          
#  position     :integer          
#  updated_at   :datetime         not null
#
class Honour < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_length_of :abbreviation, :code, :name, :allow_nil => true, :maximum => 255
  #]VALIDATORS]
  acts_as_list :scope => :nature_id
  belongs_to :nature, :class_name => "HonourNature"
  validates_presence_of :name, :abbreviation
  depends_on :nature
end
