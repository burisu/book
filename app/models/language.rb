# == Schema Information
#
# Table name: languages
#
#  created_at   :datetime      
#  id           :integer       not null, primary key
#  iso639       :string(2)     not null
#  lock_version :integer       default(0)
#  name         :string(255)   not null
#  native_name  :string(255)   
#  updated_at   :datetime      
#

class Language < ActiveRecord::Base
end
