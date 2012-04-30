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
# == Table: promotions
#
#  created_at   :datetime         not null
#  from_code    :string(255)      default("N"), not null
#  id           :integer          not null, primary key
#  is_outbound  :boolean          default(TRUE), not null
#  lock_version :integer          default(0), not null
#  name         :string(255)      not null
#  updated_at   :datetime         not null
#

# encoding: utf-8
class Promotion < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_length_of :from_code, :name, :allow_nil => true, :maximum => 255
  validates_inclusion_of :is_outbound, :in => [true, false]
  validates_presence_of :from_code, :name
  #]VALIDATORS]
  has_many :people
  has_many :questions
  
  def code
    self.name.gsub(/\s+/,'')
  end
end
