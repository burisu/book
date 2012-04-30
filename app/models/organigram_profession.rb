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
# == Table: organigram_professions
#
#  code          :string(255)      
#  created_at    :datetime         not null
#  id            :integer          not null, primary key
#  lock_version  :integer          default(0), not null
#  name          :string(255)      
#  organigram_id :integer          
#  printed       :boolean          not null
#  updated_at    :datetime         not null
#
class OrganigramProfession < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_length_of :code, :name, :allow_nil => true, :maximum => 255
  validates_inclusion_of :printed, :in => [true, false]
  #]VALIDATORS]
  # attr_accessible :title, :body
  belongs_to :organigram
  depends_on :organigram
end
