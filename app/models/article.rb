# == Schema Information
#
# Table name: articles
#
#  author_id    :integer       not null
#  bad_natures  :text          
#  body         :text          not null
#  created_at   :datetime      not null
#  document     :string(255)   
#  done_on      :date          
#  id           :integer       not null, primary key
#  intro        :string(512)   not null
#  language_id  :integer       not null
#  lock_version :integer       default(0), not null
#  opened       :boolean       not null
#  rubric_id    :integer       
#  status       :string(255)   default("W"), not null
#  title        :string(255)   not null
#  updated_at   :datetime      not null
#


class Article < ActiveRecord::Base
    
  validates_presence_of :rubric_id

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
  
  def published?
    status=='P'
  end

  def human_status
    STATUS[self.status.to_sym]
  end
  
  def self.status
    STATUS.to_a.collect{|x| [x[1],x[0].to_s]}
  end
  
end

