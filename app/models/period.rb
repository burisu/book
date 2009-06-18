# == Schema Information
# Schema version: 20090618212207
#
# Table name: periods
#
#  id           :integer         not null, primary key
#  begun_on     :date            not null
#  finished_on  :date            not null
#  person_id    :integer         not null
#  folder_id    :integer         not null
#  comment      :text            
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#  family_name  :string(255)     not null
#  address      :string(255)     not null
#  country_id   :integer         
#  latitude     :float           
#  longitude    :float           
#  photo        :string(255)     
#  phone        :string(32)      
#  fax          :string(32)      
#  email        :string(32)      
#  mobile       :string(32)      
#

class Period < ActiveRecord::Base
  
  attr_readonly :person_id, :folder_id

  def before_validation
    self.person_id = self.folder.person_id   
  end

  def validate
    if self.begun_on and self.finished_on
      errors.add(:begun_on, "ne doit pas être supérieure à la date de fin") if self.begun_on>self.finished_on
      
      if self.folder
        errors.add(:begun_on, "doit être compris dans l'intervalle du #{self.folder.begun_on.to_s} au #{self.folder.finished_on}") unless self.folder.begun_on<=self.begun_on and self.begun_on<=self.folder.finished_on
        errors.add(:finished_on, "doit être compris dans l'intervalle du #{self.folder.begun_on.to_s} au #{self.folder.finished_on}") unless self.folder.begun_on<=self.finished_on and self.finished_on<=self.folder.finished_on

        pid = self.id||0
        problem = self.folder.periods.find(:first, :conditions=>["? BETWEEN begun_on AND finished_on AND id!=?", self.begun_on, pid], :order=>'finished_on DESC')
        errors.add(:begun_on, "ne doit pas être antérieure à la fin de la période précédente : "+problem.finished_on.to_s) unless problem.nil?
        problem = self.folder.periods.find(:first, :conditions=>["? BETWEEN begun_on AND finished_on AND id!=?", self.finished_on, pid], :order=>'begun_on ASC')
        errors.add(:finished_on, "ne doit pas être postérieure au début de la période suivante : "+problem.begun_on.to_s) unless problem.nil?
        unless self.new_record?
          old_period = Period.find(self.id)
          if old_period.begun_on>self.begun_on
            problem = Period.find(:first, :conditions=>["folder_id = ? AND begun_on>=? and finished_on<? and id!=?", self.folder_id, self.begun_on, old_period.finished_on, self.id])
            errors.add(:begun_on, "ne doit pas être antérieure au début de la période précédente : "+problem.begun_on.to_s) unless problem.nil?
            
            #            errors.add(:begun_on, "ne doit pas être antérieure à plusieurs périodes") if 
            #            errors.add(:begun_on, "ne doit pas être antérieure à plusieurs périodes") if Period.count(:conditions=>["folder_id = ? AND finished_on+CAST('+2 days' AS INTERVAL) BETWEEN ? AND ? ", self.folder_id, old_period.begun_on, self.begun_on]) > 1
            #            
          end
          if old_period.finished_on<self.finished_on
            problem = Period.find(:first, :conditions=>["folder_id = ? AND finished_on<=? and begun_on>? and id!=?", self.folder_id, self.finished_on, old_period.begun_on, self.id])
            errors.add(:finished_on, "ne doit pas être postérieure à la fin de la période suivante : "+problem.finished_on.to_s) unless problem.nil?
            #         errors.add(:finished_on, "ne doit pas être postérieure à plusieurs périodes") if Period.count(:conditions=>["folder_id = ? AND begun_on+CAST('-2 days' AS INTERVAL) BETWEEN ? AND ? ", self.folder_id, old_period.finished_on, self.finished_on]) > 1
            #      end
            
          end
        end
      end
    end
  end

  def before_update
#    old_period = Period.find(self.id)
#    Period.update_all({:finished_on=>self.begun_on-1}, ["folder_id=? AND finished_on BETWEEN ? AND ?", self.folder_id, old_period.begun_on-1])
#    Period.find_all_by_finished_on(self.begun_on-1).each{|p| p.update_attributes(:folder_id=>self.folder_id, :finished_on=>old_period.begun_on-1) }
#    Period.update_all({:begun_on=>self.finished_on+1}, {:folder_id=>self.folder_id, :begun_on=>old_period.finished_on+1})
#    Period.find_all_by_begun_on(self.finished_on+1).each{|p| p.update_attributes(:folder_id=>self.folder_id, :begun_on=>old_period.finished_on+1) }
#    periods = Period.find(:all, :conditions=>{:folder_id=>self.folder_id, :finished_on=>old_period.begun_on-1})
#   for period in periods
#      period.update_attribute(:finished_on, self.begun_on-1)
#    end
#    periods = Period.find(:all, :conditions=>{:folder_id=>self.folder_id, :begun_on=>old_period.finished_on+1})
#    for period in periods
#      period.update_attribute(:begun_on, self.finished_on+1)
#    end
  end

  def name
    self.family_name+' (du '+I18n.localize(self.begun_on)+' au '+I18n.localize(self.finished_on)+')'
  end

end
