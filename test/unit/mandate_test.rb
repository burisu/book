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
# == Table: mandates
#
#  created_at   :datetime         not null
#  dont_expire  :boolean          not null
#  group_id     :integer          
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  nature_id    :integer          not null
#  person_id    :integer          not null
#  started_on   :date             not null
#  stopped_on   :date             
#  updated_at   :datetime         not null
#

