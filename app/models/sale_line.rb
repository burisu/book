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
# == Table: sale_lines
#
#  amount       :decimal(16, 2)   default(0.0), not null
#  created_at   :datetime         not null
#  description  :text             
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  name         :string(255)      not null
#  product_id   :integer          not null
#  quantity     :decimal(16, 2)   default(0.0), not null
#  sale_id      :integer          not null
#  unit_amount  :decimal(16, 2)   default(0.0), not null
#  updated_at   :datetime         not null
#

# encoding: utf-8
class SaleLine < ActiveRecord::Base
  attr_accessor :password
  belongs_to :product
  belongs_to :sale
  has_many :guests
  has_one :subscription


  def before_validation
    if self.product
      self.unit_amount = self.product.amount
      self.name ||= self.product.name
      self.description ||= self.product.description
    end
    self.quantity ||= 0.0
    self.quantity = self.guests.count if self.product.personal?
    self.quantity = 0.0 if self.quantity < 0
    self.amount = self.quantity * self.unit_amount
  end
  
  def validate
    if self.product.storable?
      errors.add(:quantity, :less_than_or_equal_to, :count=>self.product.current_quantity) if self.quantity > self.product.current_quantity
    end
  end 

  def after_save
    self.sale.save
  end

  def after_destroy
    self.sale.save
  end

end
