# == Schema Information
#
# Table name: mandate_natures
#
#  code           :string(8)     not null
#  created_at     :datetime      not null
#  id             :integer       not null, primary key
#  lock_version   :integer       default(0), not null
#  name           :string(255)   not null
#  parent_id      :integer       
#  rights         :text          
#  updated_at     :datetime      not null
#  zone_nature_id :integer       
#

class MandateNature < ActiveRecord::Base

  RIGHTS = {:all=>"Administrator", 
    :home=>"Manage articles of the home page",
    :blog=>"Gérer les articles de blog",
    :promotions=>"Manage promotions",
    :suivi=>"Manage questionnaires and answers",
    :publishing=>"Can edit and publish blog articles",
    :users=>"Manage accounts",
    :folders=>"Manage folders",
    :subscribing=>"Valid or refuse subcriptions only",
    :mandates=>"Manage mandates of people",
    :agenda=>"Manage articles of the agenda",
    :specials=>"Manage special articles"
  }

  list_column :rights, RIGHTS

  def before_validation
    self.rights = self.rights_string
  end
  
end
