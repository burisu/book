# -*- coding: utf-8 -*-
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
#  rubric_id    :integer       
#  status       :string(255)   default("W"), not null
#  title        :string(255)   not null
#  updated_at   :datetime      not null
#


class Article < ActiveRecord::Base
  belongs_to :author, :class_name=>Person.name
  belongs_to :language
  belongs_to :rubric
  has_and_belongs_to_many :mandate_natures
    
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
  
  def ready=(value)
    self.status = 'R' if value
  end

  def ready
    self.status=='R'
  end

  def ready?
    self.ready
  end

  def writing?
    self.status.to_s == 'R' or self.status.to_s == 'C'
  end
  
  def locked?
    ["R","P","U"].include? self.status
  end  
  
  def published?
    self.status=='P'
  end

  def label
    l = self.title
    l += " ("+::I18n.localize(self.done_on)+")" if self.done_on.is_a? Date
    return l
  end

  def human_status
    STATUS[self.status.to_sym]
  end
  
  def self.status
    STATUS.collect{|k,v| [v, k.to_s]}
  end

  def self.authors
    Person.find(:all, :conditions=>["id IN (SELECT author_id FROM articles)"]).collect{|a| [a.label, a.id]}
  end


  def preload(params, person)
    self.author_id ||= params["author_id"]||person.id
    self.author = person if self.author.nil? 
    self.language_id = params["language_id"]
    self.title = params["title"]
    self.intro = params["intro"]
    self.body  = params["body"]
    self.ready = params["ready"]
    self.rubric_id = params["rubric_id"]
    self.status = 'W' if self.new_record?
    self.status = params["status"] if person.rights.include? :publishing or person.admin?
    # raise params["agenda"]+' '+params["agenda"].class.to_s
    self.done_on = params["done_on"]
  end


  def to_param
    return "#{self.id}-#{self.title.parameterize[0..99]}"
  end


  def public?
    conf = Configuration.the_one
    self.rubric_id == conf.home_rubric_id or (self.rubric_id == conf.agenda_rubric_id and self.mandate_natures.empty?) or self.id == conf.about_article_id or self.id == conf.contact_article_id or self.id == conf.legals_article_id or self.id == conf.help_article_id
  end


  def can_be_read_by?(person)
    if self.mandate_natures.empty?
      return true
    else
      return !Mandate.find(:first, :conditions=>["nature_id IN (?) AND person_id=? AND CURRENT_DATE BETWEEN COALESCE(begun_on, CURRENT_DATE) AND COALESCE(finished_on, CURRENT_DATE)", self.mandate_natures.collect{|mn| mn.id}, person.id]).nil?
    end
  end

  
end

