# == Schema Information
# Schema version: 20090529124009
#
# Table name: articles
#
#  id           :integer         not null, primary key
#  title        :string(255)     not null
#  intro        :string(512)     not null
#  body         :text            not null
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
  NATURES={:default=>"Pour les membres",
           :home=>"Page d'accueil",
           :blog=>"Morceaux choisis",
           :agenda=>"Agenda",
           :about_us=>"A propos de nous (unique)",
           :contact=>"Contact (unique)",
           :legals=>"Mentions légales (unique)"}
    
  list_column :natures, NATURES
    
  STATUS = {:W=>"À l'écriture", :R=>"Prêt", :P=>"Publié", :C=>"À la correction", :U=>"Dépublié"}
  
  def content
    self.intro+"\n\n"+self.body
  end

  def created_on
    created_at.to_date
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

