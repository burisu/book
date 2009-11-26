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
#  updated_at         :datetime      
#

class Configuration < ActiveRecord::Base

  def self.parameter(*args)
    self.find(:first, :order=>"id").send(*args)
  end

end
