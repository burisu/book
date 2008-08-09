# == Schema Information
# Schema version: 20080808080808
#
# Table name: roles
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  code         :string(255)     not null
#  rights       :text            
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Role < ActiveRecord::Base

  RIGHTS = {:all=>"Administrator", 
            :home=>"Manage articles of the home page",
            :promotions=>"Manage promotions",
            :blog=>"Can edit and publish blog articles",
            :users=>"Manage accounts",
            :folders=>"Manage folders",
            :inscription_validation=>"Valid or refuse subcriptions only",
            :mandates=>"Manage mandates of people",
            :agenda=>"Manage articles of the agenda"}

  attr_protected :rights2

  def before_validation
#    self.rights = self.rights.to_s.strip.squeeze(" ").downcase
#    self.rights = self.rights_array.sort.join(" ")
  end
  
  def validate
#    self.rights_array.each{|r| errors.add_to_base("Can't manage the right :"+r.to_s) unless RIGHTS.include? r}
  end
  
  def can_manage?(level=:all)
    raise Exception.new("Unknown right to evaluate: "+level.to_s) unless RIGHTS.include? level
    rights = self.rights_array
    return rights.include?(level.to_sym) unless rights.include? :all
    return true
  end
    
  def rights=(rights)
    @rights = rights.flatten.uniq
    self["rights"] = @rights.sort{|x,y| x.to_s<=>y.to_s}.join(" ")
  end
      
  def rights
    @rights = self["rights"].to_s.split(" ").collect{|r| r.to_sym} #if @rights.nil?
    @rights
  end
  
  
  
end
