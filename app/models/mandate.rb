# == Schema Information
#
# Table name: mandates
#
#  begun_on     :date          not null
#  created_at   :datetime      not null
#  dont_expire  :boolean       not null
#  finished_on  :date          
#  id           :integer       not null, primary key
#  lock_version :integer       default(0), not null
#  nature_id    :integer       not null
#  person_id    :integer       not null
#  updated_at   :datetime      not null
#  zone_id      :integer       
#

# -*- coding: utf-8 -*-
class Mandate < ActiveRecord::Base
  belongs_to :nature, :class_name=>MandateNature.name
  belongs_to :person
  belongs_to :zone

  def validate
    if self.nature and self.zone
      if self.nature.zone_nature_id.nil?
        errors.add(:zone_id, "ne doit pas être renseigné") unless self.zone.nature_id.nil?
      elsif self.zone.nature_id != self.nature.zone_nature_id
        errors.add(:zone_id, "doit être du type #{self.nature.zone_nature.inspect}")
      end
    end
  end

  def active?(active_on=Date.today)
    self.dont_expire? or ((self.begun_on||active_on) <= active_on and active_on <= (self.finished_on||active_on))
  end

  def self.all_current(options={})
    options.merge!(:conditions=>["dont_expire OR ? BETWEEN begun_on AND COALESCE(finished_on, CURRENT_DATE)", Date.today])
    Mandate.find(:all, options)
  end

end
