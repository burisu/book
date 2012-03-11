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
# == Table: themes
#
#  color        :string(255)      default("#808080"), not null
#  comment      :text             
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  name         :string(255)      not null
#  updated_at   :datetime         not null
#

# encoding: utf-8
class Theme < ActiveRecord::Base
  has_many :questions

  def foreground_color
    Theme.gradient(self.color+"FF", "#00002260")
  end
  
  def background_color
    Theme.gradient(self.color+"FF", "#FFFFFFDD")
  end

  def self.ctoa(color)
    values = []
    for i in 0..3
      values << color.to_s[2*i+1..2*i+2].to_s.to_i(16).to_f
    end
    values
  end

  def self.atoc(color)
    code = '#'
    for x in 0..2
      code += color[x].to_i.to_s(16).rjust(2,"0")
    end
    code.upcase
  end

  def self.gradient(color1, color2)
    c1, c2 = Theme.ctoa(color1), Theme.ctoa(color2)
    r = []
    t = c2[3].to_f/255.to_f
    for i in 0..2
      r << c1[i]*(1-t)+c2[i]*t
    end
    return atoc(r)
  end
    
end
