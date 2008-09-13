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

  NATURES={:default=>"-",
           :home=>"Page d'accueil",
           :blog=>"Morceaux choisis",
           :agenda=>"Agenda",
           :about_us=>"A propos de nous (unique)",
           :contact=>"Contact (unique)",
           :legals=>"Mentions légales (unique)"}
    
    list_column :natures, NATURES


  def before_validation
    self.title_h   = textilize_without_paragraph(self.title.to_s)
    self.intro_h   = textilize(self.intro.to_s)
    self.content_h = textilize(self.intro.to_s+"\n\n"+self.body.to_s)
  end
  
  def init(params,person)
    self.author_id = person.id
    self.language_id = params[:language_id]
    self.title = params[:title]
    self.intro = params[:intro]
    self.body  = params[:body]
    self.is_published = params[:is_published] if person.can_manage? :publishing
#raise params[:agenda]+' '+params[:agenda].class.to_s
    if person.can_manage? :agenda
      self.natures_set :agenda, params[:agenda]=='1'
      self.done_on = params[:done_on]
    end
    self.natures_set :home, params[:home]=='1' if person.can_manage? :home
    self.natures_set :contact, params[:contact]=='1' if person.can_manage? :specials
    self.natures_set :about_us, params[:about_us]=='1' if person.can_manage? :specials
    self.natures_set :legals, params[:legals]=='1' if person.can_manage? :specials
  end
  
  
  def agenda
    self.natures_include? :agenda
  end
  def home
    self.natures_include? :home
  end
  def contact
    self.natures_include? :contact
  end
  def about_us
    self.natures_include? :about_us
  end
  def legals
    self.natures_include? :legals
  end
  
end

