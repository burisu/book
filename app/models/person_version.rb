# == Schema Information
#
# Table name: person_versions
#
#  address              :text          
#  arrival_country_id   :integer       
#  arrival_person_id    :integer       
#  born_on              :date          
#  comment              :text          
#  country_id           :integer       
#  created_at           :datetime      
#  departure_country_id :integer       
#  departure_person_id  :integer       
#  email                :string(255)   
#  family_id            :integer       
#  family_name          :string(255)   
#  fax                  :string(255)   
#  first_name           :string(255)   
#  hashed_password      :string(255)   
#  host_zone_id         :integer       
#  id                   :integer       not null, primary key
#  is_locked            :boolean       
#  is_user              :boolean       
#  is_validated         :boolean       
#  latitude             :float         
#  lock_version         :integer       default(0)
#  longitude            :float         
#  mobile               :string(255)   
#  patronymic_name      :string(255)   
#  person_id            :integer       
#  phone                :string(255)   
#  phone2               :string(255)   
#  photo                :string(255)   
#  promotion_id         :integer       
#  proposer_zone_id     :integer       
#  replacement_email    :string(255)   
#  role_id              :integer       
#  rotex_email          :string(255)   
#  salt                 :string(255)   
#  second_name          :string(255)   
#  sex                  :string(255)   
#  sponsor_zone_id      :integer       
#  started_on           :date          
#  stopped_on           :date          
#  student              :boolean       not null
#  updated_at           :datetime      
#  user_name            :string(255)   
#  validation           :string(255)   
#

class PersonVersion < ActiveRecord::Base
end
