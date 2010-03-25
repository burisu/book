# == Schema Information
#
# Table name: configurations
#
#  about_article_id   :integer       
#  agenda_rubric_id   :integer       
#  contact_article_id :integer       
#  created_at         :datetime      
#  home_rubric_id     :integer       
#  id                 :integer       not null, primary key
#  legals_article_id  :integer       
#  lock_version       :integer       default(0)
#  news_rubric_id     :integer       
#  store_introduction :text          
#  subscription_price :decimal(, )   default(0.0), not null
#  updated_at         :datetime      
#

class Configuration < ActiveRecord::Base


  def self.parameter(*args)
    self.find(:first, :order=>"id").send(*args)
  end

  def self.the_one
    @@configuration ||= self.find(:first, :order=>:id)
    @@configuration
  end

  @@configuration = self.the_one  
end
