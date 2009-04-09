# == Schema Information
# Schema version: 20090409220615
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
            :blog=>"Gérer les articles de blog",
            :promotions=>"Manage promotions",
            :publishing=>"Can edit and publish blog articles",
            :users=>"Manage accounts",
            :folders=>"Manage folders",
            :subscribing=>"Valid or refuse subcriptions only",
            :mandates=>"Manage mandates of people",
            :agenda=>"Manage articles of the agenda",
            :specials=>"Manage special articles"}

  list_column :rights, RIGHTS

  def before_validation
    self.rights = self.rights_string
  end
  
  def can_manage?(right=:all)
    if self.rights_include?(:all)
      return true
    else
      return self.rights_include?(right)
    end
  end
  
  def self.none
    r = Role.find(:first, :conditions=>"LENGTH(TRIM(rights))<=0")
    r = Role.create(:name=>'Nothing', :code=>'nothing') if r.nil?
    r
  end
      
end
