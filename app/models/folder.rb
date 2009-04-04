# == Schema Information
# Schema version: 20090404133338
#
# Table name: folders
#
#  id                   :integer         not null, primary key
#  person_id            :integer         not null
#  departure_country_id :integer         not null
#  arrival_country_id   :integer         not null
#  promotion_id         :integer         not null
#  begun_on             :date            not null
#  finished_on          :date            not null
#  host_zone_id         :integer         
#  sponsor_zone_id      :integer         
#  proposer_zone_id     :integer         
#  departure_person_id  :integer         
#  arrival_person_id    :integer         
#  comment              :text            
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  lock_version         :integer         default(0), not null
#

class Folder < ActiveRecord::Base
end
