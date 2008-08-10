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

  list_column :rights, RIGHTS

  def before_validation
    self.rights = self.rights_string
  end
  
  def can_manage?(right=:all)
    return self.rights_include?(right) unless self.rights_include?(:all)
    return true
  end
      
end
