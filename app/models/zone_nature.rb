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
# == Table: zone_natures
#
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  name         :string(255)      not null
#  parent_id    :integer          
#  updated_at   :datetime         not null
#

# encoding: utf-8
class ZoneNature < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_length_of :name, :allow_nil => true, :maximum => 255
  validates_presence_of :name
  #]VALIDATORS]
  belongs_to :parent, :class_name=>ZoneNature.name
  has_many :children, :class_name=>ZoneNature.name, :foreign_key=>:parent_id
  has_many :groups
end
