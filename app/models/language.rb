# == Schema Information
#
# Table name: languages
#
#  created_at   :datetime      not null
#  id           :integer       not null, primary key
#  iso639       :string(2)     not null
#  lock_version :integer       default(0), not null
#  name         :string(255)   not null
#  native_name  :string(255)   
#  updated_at   :datetime      not null
#

class Language < ActiveRecord::Base
end
