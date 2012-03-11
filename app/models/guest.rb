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
# == Table: guests
#
#  annotation   :text             
#  created_at   :datetime         not null
#  email        :string(255)      
#  first_name   :string(255)      
#  id           :integer          not null, primary key
#  last_name    :string(255)      
#  lock_version :integer          default(0), not null
#  product_id   :integer          
#  sale_id      :integer          
#  sale_line_id :integer          
#  updated_at   :datetime         not null
#  zone_id      :integer          
#

# encoding: utf-8
class Guest < ActiveRecord::Base
  belongs_to :product
  belongs_to :sale
  belongs_to :sale_line
  belongs_to :zone

  def before_validation
    if self.sale_line
      self.sale = self.sale_line.sale 
      self.product = self.sale_line.product
    end
  end

  def after_save
    self.sale_line.save
  end

  def after_destroy
    self.sale_line.save
  end

  def label
    "#{self.first_name} #{self.last_name}"
  end

end
