# -*- coding: utf-8 -*-
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
# == Table: products
#
#  active                 :boolean          not null
#  amount                 :decimal(16, 2)   default(0.0), not null
#  created_at             :datetime         
#  current_quantity       :decimal(16, 2)   default(0.0), not null
#  deadlined              :boolean          not null
#  description            :text             
#  id                     :integer          not null, primary key
#  initial_quantity       :decimal(16, 2)   default(0.0), not null
#  lock_version           :integer          default(0)
#  name                   :string(255)      not null
#  password               :string(255)      
#  passworded             :boolean          not null
#  personal               :boolean          not null
#  started_on             :date             
#  stopped_on             :date             
#  storable               :boolean          not null
#  subscribing            :boolean          not null
#  subscribing_started_on :date             
#  subscribing_stopped_on :date             
#  unit                   :string(255)      default("unités"), not null
#  updated_at             :datetime         
#

# encoding: utf-8
class Product < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_numericality_of :amount, :current_quantity, :initial_quantity, :allow_nil => true
  validates_length_of :name, :password, :unit, :allow_nil => true, :maximum => 255
  validates_inclusion_of :active, :deadlined, :passworded, :personal, :storable, :subscribing, :in => [true, false]
  validates_presence_of :amount, :current_quantity, :initial_quantity, :name, :unit
  #]VALIDATORS]
  has_many :guests
  has_many :sale_lines
  has_many :order_lines, :class_name=>SaleLine.name, :include=>:sale, :conditions=>["sales.state IN (?)", ["C", "P"]]

  scope :storables, :conditions=>{:storable=>true}, :order=>:name
  scope :usable, :conditions=>["active AND NOT deadlined OR (deadlined AND CURRENT_DATE BETWEEN started_on AND stopped_on)"], :order=>:name
  scope :saleable_to, lambda { |p|
    {:conditions=>["active AND (subscribing = ? OR subscribing IS FALSE) AND (NOT deadlined OR (deadlined AND CURRENT_DATE BETWEEN started_on AND stopped_on))", !p.nil?], :order=>:name} 
  }

  scope :unusable, :conditions=>["NOT active OR (deadlined AND NOT CURRENT_DATE BETWEEN started_on AND stopped_on)"], :order=>:name

  
  before_validation do
    self.personal = false if self.subscribing?
    return true
  end
  
  def empty_stock?
    # return (self.storable? and SaleLine.sum(:quantity, :joins=>:sale, :conditions=>["product_id=? AND sale.state IN (?)", self.id, ['C', 'P']])<= self.initial_quantity) or not self.storable?
    return ((self.storable? and self.current_quantity > 0) or not self.storable? ? true : false)
  end

  def refresh_stock
    self.current_quantity = self.initial_quantity - self.order_lines.sum(:quantity)
    self.save
    return self
  end
  
end
