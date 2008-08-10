# == Schema Information
# Schema version: 20080808080808
#
# Table name: articles
#
#  id           :integer         not null, primary key
#  title        :string(255)     not null
#  title_h      :text            not null
#  intro        :string(512)     not null
#  intro_h      :text            not null
#  body         :text            not null
#  content_h    :text            not null
#  done_on      :date            
#  natures      :text            
#  document     :string(255)     
#  is_published :boolean         not null
#  author_id    :integer         not null
#  language_id  :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Article < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  NATURES={:home=>"Article of the home page",
           :blog=>"Article of a student",
           :agenda=>"Article of the agenda (date needed)"}
  
  list_column :natures, NATURES


  def before_validation
    self.title_h   = textilize(self.title.to_s)
    self.intro_h   = textilize(self.intro.to_s)
    self.content_h = textilize(self.intro.to_s+self.body.to_s)
  end
  

  
end

