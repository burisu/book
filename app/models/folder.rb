# == Schema Information
# Schema version: 2
#
# Table name: folders
#
#  id                   :integer         not null, primary key
#  name                 :string(255)     not null
#  departure_country_id :integer         not null
#  arrival_country_id   :integer         not null
#  person_id            :integer         not null
#  promotion_id         :integer         not null
#  host_zone_id         :integer         not null
#  sponsor_zone_id      :integer         not null
#  proposer_zone_id     :integer         not null
#  arrival_person_id    :integer         not null
#  departure_person_id  :integer         not null
#  begun_on             :date            not null
#  finished_on          :date            not null
#  comment              :text            
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  lock_version         :integer         default(0), not null
#

class Folder < ActiveRecord::Base
end
