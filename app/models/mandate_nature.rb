# == Schema Information
# Schema version: 20090529124009
#
# Table name: mandate_natures
#
#  id             :integer         not null, primary key
#  name           :string(255)     not null
#  code           :string(8)       not null
#  zone_nature_id :integer         
#  parent_id      :integer         
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  lock_version   :integer         default(0), not null
#  rights         :text            
#

class MandateNature < ActiveRecord::Base

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
  
end
