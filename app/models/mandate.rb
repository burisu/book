# == Schema Information
# Schema version: 20090621154736
#
# Table name: mandates
#
#  id           :integer         not null, primary key
#  dont_expire  :boolean         not null
#  begun_on     :date            not null
#  finished_on  :date            
#  nature_id    :integer         not null
#  person_id    :integer         not null
#  zone_id      :integer         
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
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
