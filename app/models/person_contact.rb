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
# == Table: person_contacts
#
#  address      :string(255)      not null
#  by_default   :boolean          not null
#  canal        :string(255)      not null
#  city         :string(255)      
#  country      :string(255)      
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  line_2       :string(255)      
#  line_3       :string(255)      
#  line_4       :string(255)      
#  line_5       :string(255)      
#  line_6       :string(255)      
#  lock_version :integer          default(0), not null
#  nature_id    :integer          not null
#  person_id    :integer          not null
#  postcode     :string(255)      
#  receiving    :boolean          not null
#  sending      :boolean          not null
#  updated_at   :datetime         not null
#
class PersonContact < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :nature, :class_name => "PersonContactNature"
  belongs_to :person
end
