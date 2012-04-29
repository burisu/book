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
# == Table: members
#
#  comment      :text             
#  created_at   :datetime         not null
#  email        :string(255)      
#  fax          :string(32)       
#  first_name   :string(255)      not null
#  id           :integer          not null, primary key
#  last_name    :string(255)      not null
#  lock_version :integer          default(0), not null
#  mobile       :string(32)       
#  nature       :string(8)        not null
#  other_nature :string(255)      
#  person_id    :integer          not null
#  phone        :string(32)       
#  photo        :string(255)      
#  sex          :string(1)        not null
#  updated_at   :datetime         not null
#

# encoding: utf-8
class Member < ActiveRecord::Base
  belongs_to :person
  has_and_belongs_to_many :periods
  depends_on :person

  def name
    self.first_name+' '+self.last_name
  end

end
