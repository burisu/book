# == Schema Information
#
# Table name: countries
#
#  created_at   :datetime      not null
#  id           :integer       not null, primary key
#  iso3166      :string(2)     not null
#  language_id  :integer       not null
#  lock_version :integer       default(0), not null
#  name         :string(255)   not null
#  native_name  :string(255)   
#  updated_at   :datetime      not null
#

class Country < ActiveRecord::Base
  validates_uniqueness_of :iso3166

  def available_authors(conditions={})
    Person.find(:all, :conditions=>conditions.merge(:arrival_country_id=>self.id), :order=>"family_name, first_name")
  end


  def available_promotions
    Promotion.find(:all, :conditions=>{:id=>available_authors.collect{|f| f.promotion_id}}, :order=>"name")
  end

  def to_param
    self.iso3166
  end

end
