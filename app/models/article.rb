# == Schema Information
# Schema version: 2
#
# Table name: articles
#
#  id           :integer         not null, primary key
#  title        :string(255)     not null
#  intro        :string(255)     not null
#  content      :text            not null
#  summary      :string(512)     
#  html_intro   :text            
#  html_content :text            
#  html_summary :text            
#  nature_id    :integer         not null
#  author_id    :integer         not null
#  language_id  :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Article < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  def before_save
    self.html_intro=textilize self.intro
    self.html_content=textilize self.content
    self.html_summary=textilize self.summary
  end
end

