# == Schema Information
#
# Table name: mandates
#
#  begun_on     :date          not null
#  created_at   :datetime      
#  dont_expire  :boolean       not null
#  finished_on  :date          
#  id           :integer       not null, primary key
#  lock_version :integer       default(0)
#  nature_id    :integer       not null
#  person_id    :integer       not null
#  updated_at   :datetime      
#  zone_id      :integer       
#

class Mandate < ActiveRecord::Base

  def validate
    if self.nature and self.zone
      if self.nature.zone_nature_id.nil?
        errors.add(:zone_id, "ne doit pas être renseigné") unless self.zone.nature_id.nil?
      elsif self.zone.nature_id != self.nature.zone_nature_id
        errors.add(:zone_id, "doit être du type #{self.nature.zone_nature.inspect}")
      end
    end
  end

  def self.all_current(options={})
    options.merge!(:conditions=>["dont_expire OR ? BETWEEN begun_on AND COALESCE(finished_on, CURRENT_DATE)", Date.today])
    Mandate.find(:all, options)
  end

end
