# == Schema Information
# Schema version: 20090404133338
#
# Table name: languages
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  native_name  :string(255)     
#  iso639       :string(2)       not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Language < ActiveRecord::Base
end
