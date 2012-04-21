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
# == Table: group_natures
#
#  created_at      :datetime         not null
#  id              :integer          not null, primary key
#  lock_version    :integer          default(0), not null
#  name            :string(255)      
#  organization_id :integer          
#  updated_at      :datetime         not null
#  zone_nature_id  :integer          
#


# encoding: utf-8
class GroupNature < ActiveRecord::Base
  has_many :groups
  belongs_to :organization
  belongs_to :zone_nature
end
