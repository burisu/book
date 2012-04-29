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
# == Table: group_kinships
#
#  child_id        :integer          
#  created_at      :datetime         not null
#  id              :integer          not null, primary key
#  lock_version    :integer          default(0), not null
#  organization_id :integer          
#  parent_id       :integer          
#  updated_at      :datetime         not null
#


# encoding: utf-8
class GroupKinship < ActiveRecord::Base
  belongs_to :organization
  belongs_to :parent, :class_name => "Group"
  belongs_to :child, :class_name => "Group"
  depends_on :parent, :child
end
