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
  validates_presence_of :host_zone_id, :proposer_zone_id

  def before_validation
    self.departure_country_id = self.proposer_zone.country_id if self.proposer_zone
    self.arrival_country_id = self.host_zone.country_id if self.host_zone
    if self.begun_on and self.departure_country
      from = (self.begun_on.month>=5 ? 'N' : 'S')
      out = (self.departure_country.iso3166.lower == 'fr' ? true : false)
      pn = "#{out ? 'Out' : 'In'} #{self.begun_on.year} #{from}"
      promotion = Promotion.find_by_name(pn)
      promotion = Promotion.create(:name=>pn, :is_outbound=>out, :from_code=>from) if promotion.nil?
      self.promotion_id = promotion.id
    end
  end

  def validate
    if self.proposer_zone and self.host_zone
      errors.add_to_base("Le club d'origine ou le club hôte doit se trouver en France") if self.proposer_zone.country.iso3166.lower != 'fr' and self.host_zone.country.iso3166.lower != 'fr'
    end
#     if self.proposer_zone
#       errors.add(:proposer_zone_id, "ne correspond pas au pays de départ") if self.proposer_zone.country_id!=self.departure_country_id
#     end
#     if self.host_zone
#       errors.add(:host_zone_id, "ne correspond pas au pays d'arrivée") if self.host_zone.country_id!=self.arrival_country_id
#     end
  end

  def reports
    Article.find(:all, :conditions=>{:author_id=>self.person_id, :rubric_id=>Configuration.the_one.news_rubric_id}, :order=>"done_on");
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
