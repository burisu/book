# == Schema Information
# Schema version: 20090409220615
#
# Table name: zones
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  number       :integer         not null
#  code         :text            not null
#  nature_id    :integer         
#  parent_id    :integer         
#  country_id   :integer         
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Zone < ActiveRecord::Base
  
  def before_validation
    self.code = self.parent ? self.parent.code : ''
    self.code += '/'+self.number.to_s
  end

  def validate 
    if self.nature and !self.nature.parent.nil?
      errors.add(:parent_id, "doit être du type \""+self.nature.parent.name+"\" ") if self.parent and self.parent.nature != self.nature.parent
      errors.add(:parent_id, "doit être renseigné") if self.parent.nil? and !self.nature.parent.nil?
    elsif self.nature and self.nature.parent.nil?
      errors.add(:parent_id, "ne doit pas être renseigné") unless self.parent.nil?
    end
  end

  def after_save
    Zone.find(:all, :conditions=>{:parent_id=>self.id}).each do |zone| 
      zone.save
    end    
  end

  def scaffold_name
    code = self.name
    code +=' ('+self.parent.name+')' if self.parent
    code
  end

  def parents
    parents = self.parent ? self.parent.parents : []
    parents << self
    parents
  end
  
end
