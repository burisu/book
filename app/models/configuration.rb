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
# == Table: configurations
#
#  about_article_id                    :integer          
#  agenda_rubric_id                    :integer          
#  chasing_up_days                     :string(255)      
#  chasing_up_letter_after_expiration  :text             
#  chasing_up_letter_before_expiration :text             
#  contact_article_id                  :integer          
#  created_at                          :datetime         not null
#  help_article_id                     :integer          
#  home_rubric_id                      :integer          
#  id                                  :integer          not null, primary key
#  legals_article_id                   :integer          
#  lock_version                        :integer          default(0), not null
#  news_rubric_id                      :integer          
#  store_introduction                  :text             
#  subscription_price                  :decimal(, )      default(0.0), not null
#  updated_at                          :datetime         not null
#

# encoding: utf-8
class Configuration < ActiveRecord::Base
  belongs_to :about_article, :class_name=>Article.name
  belongs_to :agenda_rubric, :class_name=>Rubric.name
  belongs_to :contact_article, :class_name=>Article.name
  belongs_to :help_article, :class_name=>Article.name
  belongs_to :home_rubric, :class_name=>Rubric.name
  belongs_to :legals_article, :class_name=>Article.name
  belongs_to :news_rubric, :class_name=>Rubric.name

  def self.parameter(*args)
    self.find(:first, :order=>"id").send(*args)
  end

  def self.the_one
    @@configuration ||= self.find(:first, :order=>:id)
    @@configuration
  end

  def chasing_up_days_array
    self.chasing_up_days.to_s.split(/[\,\s]+/).collect{|x| x.to_i}.sort
  end

  def first_chasing_up
    chasing_up_days_array[0]
  end

  def last_chasing_up
    chasing_up_days_array[-1]
  end

  @@configuration = self.the_one
end
