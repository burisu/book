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
# == Table: mandates
#
#  created_at   :datetime         not null
#  dont_expire  :boolean          not null
#  group_id     :integer          
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  nature_id    :integer          not null
#  person_id    :integer          not null
#  started_on   :date             not null
#  stopped_on   :date             
#  updated_at   :datetime         not null
#

# -*- coding: utf-8 -*-
# coding: utf-8
class Mandate < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_inclusion_of :dont_expire, :in => [true, false]
  validates_presence_of :nature, :person, :started_on
  #]VALIDATORS]
  belongs_to :nature, :class_name=>"MandateNature"
  belongs_to :person
  belongs_to :group
  depends_on :person
  validates_presence_of :group, :nature, :person

  validate do
    if self.nature and self.group
      if self.nature.zone_nature_id.nil?
        errors.add(:group_id, "ne doit pas être renseigné") unless self.group.nature_id.nil?
      elsif self.group.nature_id != self.nature.zone_nature_id
        errors.add(:group_id, "doit être du type #{self.nature.zone_nature.inspect}")
      end
    end
  end

  def active?(active_on=Date.today)
    self.dont_expire? or ((self.begun_on||active_on) <= active_on and active_on <= (self.finished_on||active_on))
  end

  def self.all_current(options={})
    options.merge!(:conditions=>["dont_expire OR ? BETWEEN begun_on AND COALESCE(finished_on, CURRENT_DATE)", Date.today])
    Mandate.find(:all, options)
  end

end
