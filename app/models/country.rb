# == Schema Information
# Schema version: 20090324204319
#
# Table name: countries
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  native_name  :string(255)     
#  iso3166      :string(2)       not null
#  language_id  :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Country < ActiveRecord::Base
end
