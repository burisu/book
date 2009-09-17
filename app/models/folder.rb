# == Schema Information
#
# Table name: folders
#
#  arrival_country_id   :integer       not null
#  arrival_person_id    :integer       
#  begun_on             :date          not null
#  comment              :text          
#  created_at           :datetime      not null
#  departure_country_id :integer       not null
#  departure_person_id  :integer       
#  finished_on          :date          not null
#  host_zone_id         :integer       
#  id                   :integer       not null, primary key
#  lock_version         :integer       default(0), not null
#  person_id            :integer       not null
#  promotion_id         :integer       not null
#  proposer_zone_id     :integer       
#  sponsor_zone_id      :integer       
#  updated_at           :datetime      not null
#

class Folder < ActiveRecord::Base

  def reports
    Article.find(:all, :conditions=>["author_id=? AND done_on IS NOT NULL AND natures NOT LIKE '%agenda%'", self.person_id], :order=>:done_on);
  end

  def current?
    self.begun_on <= Date.today and Date.today <= self.finished_on
  end

  def before_destroy
    self.periods.each do |p|
      p.destroy
    end
  end

end
