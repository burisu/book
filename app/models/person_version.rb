# == Schema Information
# Schema version: 20090529124009
#
# Table name: person_versions
#
#  id                :integer         not null, primary key
#  person_id         :integer         
#  patronymic_name   :string(255)     
#  family_name       :string(255)     
#  family_id         :integer         
#  first_name        :string(255)     
#  second_name       :string(255)     
#  user_name         :string(255)     
#  photo             :string(255)     
#  country_id        :integer         
#  sex               :string(255)     
#  born_on           :date            
#  address           :text            
#  latitude          :float           
#  longitude         :float           
#  phone             :string(255)     
#  phone2            :string(255)     
#  fax               :string(255)     
#  mobile            :string(255)     
#  email             :string(255)     
#  replacement_email :string(255)     
#  hashed_password   :string(255)     
#  salt              :string(255)     
#  rotex_email       :string(255)     
#  validation        :string(255)     
#  is_validated      :boolean         
#  is_locked         :boolean         
#  is_user           :boolean         
#  role_id           :integer         
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  lock_version      :integer         default(0), not null
#

class PersonVersion < ActiveRecord::Base
end
