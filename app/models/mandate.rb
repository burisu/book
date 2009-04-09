# == Schema Information
# Schema version: 20090409220615
#
# Table name: mandates
#
#  id           :integer         not null, primary key
#  dont_expire  :boolean         not null
#  begun_on     :date            not null
#  finished_on  :date            
#  nature_id    :integer         not null
#  person_id    :integer         not null
#  zone_id      :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Mandate < ActiveRecord::Base
end
