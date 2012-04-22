# encoding: utf-8
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
# == Table: groups
#
#  code           :text             not null
#  country        :string(2)        
#  created_at     :datetime         not null
#  id             :integer          not null, primary key
#  lock_version   :integer          default(0), not null
#  name           :string(255)      not null
#  number         :integer          not null
#  parent_id      :integer          
#  updated_at     :datetime         not null
#  zone_nature_id :integer          
#

# -*- coding: utf-8 -*-
# encoding: utf-8
class Group < ActiveRecord::Base
  attr_accessible :country, :name, :number, :parent_id, :zone_nature_id
  belongs_to :nature, :class_name=>"GroupNature"
  belongs_to :parent, :class_name=>"Group"
  belongs_to :zone_nature
  has_many :interventions, :class_name => "GroupIntervention"
  default_scope order(:code)

  # has_many :children, :class_name=>self.class.name, :foreign_key=>:parent_id
  scope :roots, :conditions=>["parent_id IS NULL"], :order=>:name
  
  before_validation do
    self.code = self.parent ? self.parent.code : ''
    self.code += '/'+self.number.to_s.rjust(6, "0")
  end

  validate do
    if self.nature and !self.nature.parent.nil?
      errors.add(:parent_id, "doit être du type \""+self.nature.parent.name+"\" ") if self.parent and self.parent.nature != self.nature.parent
      errors.add(:parent_id, "doit être renseigné") if self.parent.nil? and !self.nature.parent.nil?
    elsif self.nature and self.nature.parent.nil?
      errors.add(:parent_id, "ne doit pas être renseigné") unless self.parent.nil?
    end
  end

  after_save do
    Group.find(:all, :conditions=>{:parent_id=>self.id}).each do |zone| 
      zone.save
    end    
  end

  def scaffold_name
    code = self.name
    code +=' ('+self.parent.name+')' if self.parent
    code
  end

  def parents
    parents = self.parent ? self.parent.parents : []
    parents << self
    parents
  end
  
  def children
    self.class.find(:all, :conditions=>["parent_id = ?", self.id], :order=>:number)
  end

  def natures
    if self.parent
      ZoneNature.find(:all, :conditions=>["parent_id=?", @parent.nature_id ], :order=>:name)
    else
      ZoneNature.find(:all, :conditions=>["parent_id IS NULL"], :order=>:name)
    end
  end

  def in_zone?(zone)
    return true if self.id == zone.id 
    if self.parent
      return true if self.parent.in_zone?(zone)
    end
  end

  def self.list(conditions={})
    if conditions.is_a?(String) and nature = ZoneNature.find(:first, :conditions=>["LOWER(name) LIKE ?", conditions])
      conditions = ["zones.nature_id = ? ", nature.id]
    end
    Group.find(:all, 
              :select=>"district.name||' - '||groups.name AS long_name, groups.id AS zid", 
              :joins=>" join groups as zse on (groups.parent_id=zse.id) join groups as district on (zse.parent_id=district.id)", 
              :conditions=>conditions, 
              :order=>"district.name, groups.name").collect {|p| [ p[:long_name], p[:zid].to_i ] }||[]
  end
  
end
