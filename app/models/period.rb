# == Schema Information
# Schema version: 20090324204319
#
# Table name: periods
#
#  id           :integer         not null, primary key
#  begun_on     :date            not null
#  finished_on  :date            not null
#  person_id    :integer         not null
#  folder_id    :integer         not null
#  family_id    :integer         not null
#  comment      :text            
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Period < ActiveRecord::Base
  def before_validation
    self.person_id = self.folder.person_id   
  end
end
