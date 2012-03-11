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
# == Table: subscriptions
#
#  begun_on     :date             not null
#  created_at   :datetime         not null
#  finished_on  :date             not null
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  number       :string(64)       
#  person_id    :integer          not null
#  sale_id      :integer          
#  sale_line_id :integer          
#  updated_at   :datetime         not null
#

# encoding: utf-8
class Subscription < ActiveRecord::Base
  attr_readonly :number
  belongs_to :person
  belongs_to :sale
  belongs_to :sale_line
  validates_uniqueness_of :number

  def before_validation_on_create
    last = self.class.find(:first, :order=>"id DESC")
    self.number = Time.now.to_i.to_s(36)+(last ? last.id+1 : 0).to_s(36).rjust(6, '0')
    self.number.upcase!
    return true
  end

  def self.chase_up(done_on=nil)
    done_on ||= Date.today
    conf = Configuration.the_one
    days = conf.chasing_up_days_array
    ps = {}
    for day in days
      original_message = (day >= 0 ? conf.chasing_up_letter_after_expiration : conf.chasing_up_letter_before_expiration)
      expired_on = done_on+day
      for sub in self.find(:all, :conditions=>["finished_on = ? AND person_id NOT IN (SELECT person_id FROM subscriptions WHERE finished_on > ?)", expired_on, expired_on])
        person = sub.person
        message = original_message.gsub(/\[[^\]]+\]/) do |m|
          m = m[1..-2]
          if m == "count"
            days.abs.to_s
          elsif person.respond_to? m
            person.send(m).to_s
          end
        end
        Maily.deliver_chase(sub, message)
        ps[day.to_s] ||= []
        ps[day.to_s] << person
      end
    end
    return ps
  end
      


end
