# == Schema Information
# Schema version: 20090324204319
#
# Table name: images
#
#  id           :integer         not null, primary key
#  title        :string(255)     not null
#  title_h      :text            not null
#  desc         :string(255)     
#  desc_h       :text            
#  document     :string(255)     not null
#  person_id    :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#  name         :string(255)     not null
#

class Image < ActiveRecord::Base
  

end
