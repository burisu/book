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
# == Table: periods
#
#  address      :string(255)      not null
#  begun_on     :date             not null
#  comment      :text             
#  country      :string(2)        
#  created_at   :datetime         not null
#  email        :string(32)       
#  family_name  :string(255)      not null
#  fax          :string(32)       
#  finished_on  :date             not null
#  id           :integer          not null, primary key
#  latitude     :float            
#  lock_version :integer          default(0), not null
#  longitude    :float            
#  mobile       :string(32)       
#  person_id    :integer          not null
#  phone        :string(32)       
#  photo        :string(255)      
#  updated_at   :datetime         not null
#

# encoding: utf-8
class Period < ActiveRecord::Base
  belongs_to :country
  belongs_to :person
  has_and_belongs_to_many :members
  
  attr_readonly :person_id

  def validate
    if self.begun_on and self.finished_on
      errors.add(:begun_on, "ne doit pas être supérieure à la date de fin") if self.begun_on>self.finished_on
      
      if self.person
        errors.add(:begun_on, "doit être compris dans l'intervalle du #{self.person.started_on.to_s} au #{self.person.stopped_on}") unless self.person.started_on<=self.begun_on and self.begun_on<=self.person.stopped_on
        errors.add(:finished_on, "doit être compris dans l'intervalle du #{self.person.started_on.to_s} au #{self.person.stopped_on}") unless self.person.started_on<=self.finished_on and self.finished_on<=self.person.stopped_on

        pid = self.id||0
        problem = self.person.periods.find(:first, :conditions=>["? BETWEEN begun_on AND finished_on AND id!=?", self.begun_on, pid], :order=>'finished_on DESC')
        errors.add(:begun_on, "ne doit pas être antérieure à la fin de la période précédente : "+problem.finished_on.to_s) unless problem.nil?
        problem = self.person.periods.find(:first, :conditions=>["? BETWEEN begun_on AND finished_on AND id!=?", self.finished_on, pid], :order=>'begun_on ASC')
        errors.add(:finished_on, "ne doit pas être postérieure au début de la période suivante : "+problem.begun_on.to_s) unless problem.nil?
        unless self.new_record?
          old_period = Period.find(self.id)
          if old_period.begun_on>self.begun_on
            problem = Period.find(:first, :conditions=>["person_id = ? AND begun_on>=? and finished_on<? and id!=?", self.person_id, self.begun_on, old_period.finished_on, self.id])
            errors.add(:begun_on, "ne doit pas être antérieure au début de la période précédente : "+problem.begun_on.to_s) unless problem.nil?
            
            #            errors.add(:begun_on, "ne doit pas être antérieure à plusieurs périodes") if 
            #            errors.add(:begun_on, "ne doit pas être antérieure à plusieurs périodes") if Period.count(:conditions=>["person_id = ? AND finished_on+CAST('+2 days' AS INTERVAL) BETWEEN ? AND ? ", self.person_id, old_period.begun_on, self.begun_on]) > 1
            #            
          end
          if old_period.finished_on<self.finished_on
            problem = Period.find(:first, :conditions=>["person_id = ? AND finished_on<=? and begun_on>? and id!=?", self.person_id, self.finished_on, old_period.begun_on, self.id])
            errors.add(:finished_on, "ne doit pas être postérieure à la fin de la période suivante : "+problem.finished_on.to_s) unless problem.nil?
            #         errors.add(:finished_on, "ne doit pas être postérieure à plusieurs périodes") if Period.count(:conditions=>["person_id = ? AND begun_on+CAST('-2 days' AS INTERVAL) BETWEEN ? AND ? ", self.person_id, old_period.finished_on, self.finished_on]) > 1
            #      end
            
          end
        end
      end
    end
  end

  def before_update
#    old_period = Period.find(self.id)
#    Period.update_all({:finished_on=>self.begun_on-1}, ["person_id=? AND finished_on BETWEEN ? AND ?", self.person_id, old_period.begun_on-1])
#    Period.find_all_by_finished_on(self.begun_on-1).each{|p| p.update_attributes(:person_id=>self.person_id, :finished_on=>old_period.begun_on-1) }
#    Period.update_all({:begun_on=>self.finished_on+1}, {:person_id=>self.person_id, :begun_on=>old_period.finished_on+1})
#    Period.find_all_by_begun_on(self.finished_on+1).each{|p| p.update_attributes(:person_id=>self.person_id, :begun_on=>old_period.finished_on+1) }
#    periods = Period.find(:all, :conditions=>{:person_id=>self.person_id, :finished_on=>old_period.begun_on-1})
#   for period in periods
#      period.update_attribute(:finished_on, self.begun_on-1)
#    end
#    periods = Period.find(:all, :conditions=>{:person_id=>self.person_id, :begun_on=>old_period.finished_on+1})
#    for period in periods
#      period.update_attribute(:begun_on, self.finished_on+1)
#    end
  end

  def name
    self.family_name+' (du '+I18n.localize(self.begun_on)+' au '+I18n.localize(self.finished_on)+')'
  end

end
