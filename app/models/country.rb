# == Schema Information
# Schema version: 20090621154736
#
# Table name: countries
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  native_name  :string(255)     
#  iso3166      :string(2)       not null
#  language_id  :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Country < ActiveRecord::Base

  def available_authors
    Person.find(:all, :conditions=>{:id=>Folder.find_all_by_arrival_country_id(self.id).collect{|f| f.person_id}}, :order=>"family_name, first_name")
  end

end
