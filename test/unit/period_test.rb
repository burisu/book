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
# == Table: periods
#
#  address      :string(255)      not null
#  begun_on     :date             not null
#  comment      :text             
#  country      :string(2)        
#  created_at   :datetime         not null
#  email        :string(32)       
#  family_name  :string(255)      not null
#  fax          :string(32)       
#  finished_on  :date             not null
#  id           :integer          not null, primary key
#  latitude     :float            
#  lock_version :integer          default(0), not null
#  longitude    :float            
#  mobile       :string(32)       
#  person_id    :integer          not null
#  phone        :string(32)       
#  photo        :string(255)      
#  updated_at   :datetime         not null
#

