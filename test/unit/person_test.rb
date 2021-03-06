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
# == Table: people
#
#  activity_id         :integer          
#  approved            :boolean          not null
#  arrival_country     :string(2)        
#  arrival_person_id   :integer          
#  birth_country       :string(2)        
#  born_on             :date             not null
#  comment             :text             
#  created_at          :datetime         not null
#  departure_country   :string(2)        
#  departure_person_id :integer          
#  email               :string(255)      not null
#  family_name         :string(255)      not null
#  first_name          :string(255)      not null
#  hashed_password     :string(255)      
#  host_zone_id        :integer          
#  id                  :integer          not null, primary key
#  is_locked           :boolean          not null
#  is_user             :boolean          not null
#  is_validated        :boolean          not null
#  language            :string(2)        
#  latitude            :float            
#  lock_version        :integer          default(0), not null
#  longitude           :float            
#  patronymic_name     :string(255)      not null
#  photo_content_type  :string(255)      
#  photo_file_name     :string(255)      
#  photo_file_size     :integer          
#  photo_updated_at    :datetime         
#  profession_id       :integer          
#  promotion_id        :integer          
#  proposer_zone_id    :integer          
#  replacement_email   :string(255)      
#  rotex_email         :string(255)      
#  salt                :string(255)      
#  second_name         :string(255)      
#  sex                 :string(1)        not null
#  sponsor_zone_id     :integer          
#  started_on          :date             
#  stopped_on          :date             
#  student             :boolean          not null
#  updated_at          :datetime         not null
#  user_name           :string(32)       not null
#  validation          :string(255)      
#

