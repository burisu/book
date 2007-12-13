# == Schema Information
# Schema version: 2
#
# Table name: person_versions
#
#  id               :integer         not null, primary key
#  patronymic_name  :string(255)     not null
#  family_name      :string(255)     
#  first_name       :string(255)     not null
#  second_name      :string(255)     
#  is_female        :boolean         default(TRUE), not null
#  born_on          :date            not null
#  home_address     :text            not null
#  aligned_to_right :boolean         not null
#  home_phone       :string(32)      
#  work_phone       :string(32)      
#  fax              :string(32)      
#  mobile           :string(32)      
#  messenger_email  :string(255)     
#  user_name        :string(32)      not null
#  email            :string(255)     not null
#  hashed_password  :string(255)     not null
#  salt             :string(255)     not null
#  rotex_email      :string(255)     
#  is_locked        :boolean         not null
#  photo            :string(255)     
#  country_id       :integer         not null
#  role_id          :integer         not null
#  person_id        :integer         not null
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  lock_version     :integer         default(0), not null
#

class PersonVersion < ActiveRecord::Base
end
