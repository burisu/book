# == Schema Information
#
# Table name: zones
#
#  code         :text          not null
#  country_id   :integer       
#  created_at   :datetime      not null
#  id           :integer       not null, primary key
#  lock_version :integer       default(0), not null
#  name         :string(255)   not null
#  nature_id    :integer       
#  number       :integer       not null
#  parent_id    :integer       
#  updated_at   :datetime      not null
#

class Zone < ActiveRecord::Base
  
  def before_validation
    self.code = self.parent ? self.parent.code : ''
    self.code += '/'+self.number.to_s.rjust(6, "0")
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

  def children
    self.class.find(:all, :conditions=>{:parent_id => self.id})
  end

  def in_zone?(zone)
    return true if self.id == zone.id 
    if self.parent
      return true if self.parent.in_zone?(zone)
    end
  end

  def self.list(conditions={})
    Zone.find(:all, 
              :select=>"co.name||' - '||district.name||' - '||zones.name AS long_name, zones.id AS zid", 
              :joins=>" join zones as zse on (zones.parent_id=zse.id) join zones as district on (zse.parent_id=district.id) join countries AS co ON (zones.country_id=co.id)", 
              :conditions=>conditions, 
              :order=>"co.iso3166, district.name, zones.name").collect {|p| [ p[:long_name], p[:zid].to_i ] }||[]
  end
  
end
