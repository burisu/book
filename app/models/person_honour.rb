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
# == Table: person_honours
#
#  comment      :text             
#  created_at   :datetime         not null
#  given_on     :date             
#  honour_id    :integer          not null
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  person_id    :integer          not null
#  updated_at   :datetime         not null
#
class PersonHonour < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_presence_of :honour, :person
  #]VALIDATORS]
  # attr_accessible :title, :body
  belongs_to :honour
  belongs_to :person
  depends_on :person, :honour
end
