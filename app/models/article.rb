# == Schema Information
# Schema version: 20090404133338
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
#  status       :string(255)     default("W"), not null
#  document     :string(255)     
#  author_id    :integer         not null
#  language_id  :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Article < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  NATURES={:default=>"Pour les membres",
           :home=>"Page d'accueil",
           :blog=>"Morceaux choisis",
           :agenda=>"Agenda",
           :about_us=>"A propos de nous (unique)",
           :contact=>"Contact (unique)",
           :legals=>"Mentions légales (unique)"}
    
  list_column :natures, NATURES
    
  STATUS = {:W=>"À l'écriture", :R=>"Prêt", :P=>"Publié", :C=>"À la correction", :U=>"Dépublié"}

  def before_validation
    self.title_h   = textilize_without_paragraph(self.title.to_s)
    self.intro_h   = textilize(self.intro.to_s)
    self.content_h = textilize(self.intro.to_s+"\n\n"+self.body.to_s)
  end
  
  def init(params,person)
    self.author_id ||= person.id
    self.language_id = params[:language_id]
    self.title = params[:title]
    self.intro = params[:intro]
    self.body  = params[:body]
    self.status = 'W' if self.new_record?
    self.status = params[:status] if person.can_manage? :publishing
#raise params[:agenda]+' '+params[:agenda].class.to_s
    if person.can_manage? :agenda
      self.natures_set :agenda, params[:agenda]=='1'
      self.done_on = params[:done_on]
    end
    self.natures_set :blog, params[:blog]=='1' if person.can_manage? :blog
    self.natures_set :home, params[:home]=='1' if person.can_manage? :home
    self.natures_set :contact, params[:contact]=='1' if person.can_manage? :specials
    self.natures_set :about_us, params[:about_us]=='1' if person.can_manage? :specials
    self.natures_set :legals, params[:legals]=='1' if person.can_manage? :specials
  end
  
  def to_correct
    self.update_attribute(:status, 'C')
  end

  def to_publish
    self.update_attribute(:status, 'R')
  end

  def publish
    self.update_attribute(:status, 'P')
  end
  
  def unpublish
    self.update_attribute(:status, 'U')
  end
  
  def ready?
    status=='R'
  end
  
  def locked?
    ["R","P","U"].include? self.status
  end  
  
  def human_status
    STATUS[self.status.to_sym]
  end
  
  def self.status
    STATUS.to_a.collect{|x| [x[1],x[0].to_s]}
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
  def blog
    self.natures_include? :blog
  end
  
end

