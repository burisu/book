# coding: utf-8
# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2012 Brice Texier, Thibaud Merigon
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
# 
# == Table: people
#
#  activity_id         :integer          
#  approved            :boolean          not null
#  arrival_country     :string(2)        
#  arrival_person_id   :integer          
#  birth_country       :string(2)        
#  born_on             :date             not null
#  comment             :text             
#  created_at          :datetime         not null
#  departure_country   :string(2)        
#  departure_person_id :integer          
#  email               :string(255)      not null
#  family_name         :string(255)      not null
#  first_name          :string(255)      not null
#  hashed_password     :string(255)      
#  host_zone_id        :integer          
#  id                  :integer          not null, primary key
#  is_locked           :boolean          not null
#  is_user             :boolean          not null
#  is_validated        :boolean          not null
#  language            :string(2)        
#  latitude            :float            
#  lock_version        :integer          default(0), not null
#  longitude           :float            
#  patronymic_name     :string(255)      not null
#  photo_content_type  :string(255)      
#  photo_file_name     :string(255)      
#  photo_file_size     :integer          
#  photo_updated_at    :datetime         
#  profession_id       :integer          
#  promotion_id        :integer          
#  proposer_zone_id    :integer          
#  replacement_email   :string(255)      
#  rotex_email         :string(255)      
#  salt                :string(255)      
#  second_name         :string(255)      
#  sex                 :string(1)        not null
#  sponsor_zone_id     :integer          
#  started_on          :date             
#  stopped_on          :date             
#  student             :boolean          not null
#  updated_at          :datetime         not null
#  user_name           :string(32)       not null
#  validation          :string(255)      
#

# -*- coding: utf-8 -*-
# encoding: utf-8
require 'digest/sha2'

class Person < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_numericality_of :photo_file_size, :allow_nil => true, :only_integer => true
  validates_numericality_of :latitude, :longitude, :allow_nil => true
  validates_length_of :sex, :allow_nil => true, :maximum => 1
  validates_length_of :arrival_country, :birth_country, :departure_country, :language, :allow_nil => true, :maximum => 2
  validates_length_of :user_name, :allow_nil => true, :maximum => 32
  validates_length_of :email, :family_name, :first_name, :hashed_password, :patronymic_name, :photo_content_type, :photo_file_name, :replacement_email, :rotex_email, :salt, :second_name, :validation, :allow_nil => true, :maximum => 255
  validates_inclusion_of :approved, :is_locked, :is_user, :is_validated, :student, :in => [true, false]
  validates_presence_of :born_on, :email, :family_name, :first_name, :patronymic_name, :sex, :user_name
  #]VALIDATORS]
  # apply_simple_captcha :message => "Le texte est différent de l'image de vérification", :add_to_base => true
  attr_protected :latitude, :longitude, :arrival_person_id, :started_on, :stopped_on, :departure_person_id, :host_zone_id, :proposer_zone_id, :sponsor_zone_id, :approved, :arrival_country, :departure_country
  attr_accessor :password_confirmation
  attr_accessor :test_password
  attr_accessor :terms_of_use
  attr_accessor :forced
  attr_protected :replacement_email, :is_locked, :is_validated, :validation, :salt, :hashed_password, :forced, :is_user
  # TODO: Convert to paperclip
  # file_column :photo, :magick => {:versions => { "thumb"=> "100x150", "portrait" => {:crop=>"2:3", :size=>"300x450"}, "medium" => "600x900>", "big"=>"1200x1800>" } }
  has_attached_file :photo, :styles => { :thumb => "100x150", :portrait => "300x450#", :medium => "600x900>", :big => "1200x1800>" }
  belongs_to :activity
  # belongs_to :arrival_country, :class_name=>"Country"
  belongs_to :arrival_person, :class_name=>"Person"
  # belongs_to :country
  # belongs_to :departure_country, :class_name=>"Country"
  belongs_to :departure_person, :class_name=>"Person"
  # belongs_to :family_id
  belongs_to :host_zone, :class_name=>"Group"
  belongs_to :profession, :class_name => "OrganigramProfession"
  belongs_to :promotion
  belongs_to :proposer_zone, :class_name=>"Group"
  belongs_to :sponsor_zone, :class_name=>"Group"
  has_many :answers
  has_many :articles, :foreign_key=>:author_id
  has_many :images
  has_many :members, :order=>"last_name, first_name"
  has_many :periods
  has_many :sales, :foreign_key=>:client_id
  has_many :subscriptions
  # has_many :orders, :foreign_key=>:client_id, :class_name=>"Sale", :conditions=>{:state=>'C'}
  has_many :mandates
  validates_acceptance_of :terms_of_use
  validates_confirmation_of :password
  validates_format_of :user_name, :with=>/[a-z0-9\_]{4,32}/
  validates_length_of :user_name, :in=>4..32
  validates_uniqueness_of :email, :user_name  #, :if=>Proc.new {|p| !p.system }
  validates_presence_of :proposer_zone, :sponsor_zone, :if=>Proc.new{|x| !x.started_on.nil?}
  validates_presence_of :host_zone, :if=>Proc.new{|x| !x.stopped_on.nil?}

  before_validation do
    # self.user_name = self.user_name.lower.gsub(/\W+/, '')
    self.patronymic_name = self.patronymic_name.to_s.upcase
    self.family_name = self.family_name.to_s.upcase
    self.family_name = self.patronymic_name if self.family_name.blank?
    self.forced = false if self.forced.nil?
    self.user_name.gsub!(/(-|\.|\ )/, '')
    self.rotex_email = self.first_name.to_s.strip.gsub(/\s*\-\s*/, '-').gsub(/\s+/, '_').lower_ascii+'.'+self.patronymic_name.strip.gsub(/\s*\-\s*/, '-').gsub(/\s+/, '_').lower_ascii+'@rotex1690.org'

    self.validation = Person.generate_password(73+2*(10*rand).to_i) unless self.is_validated or !self.replacement_email.blank?
    if self.latitude.blank?
      pm = Geocoding.get(self.address)
      if pm.size==1
        if pm[0].accuracy>=8
          self.address                 = pm[0].address
          self.latitude                = pm[0].latitude
          self.longitude               = pm[0].longitude
        end
      end      
    end

    self.departure_country_id = self.proposer_zone.country_id if self.proposer_zone
    self.arrival_country_id = self.host_zone.country_id if self.host_zone
    if self.started_on and self.departure_country
      from = (self.started_on.month>=5 ? 'N' : 'S')
      out = (self.departure_country.iso3166.lower == 'fr' ? true : false)
      pn = "#{out ? 'Out' : 'In'} #{self.started_on.year} #{from}"
      promotion = Promotion.find_by_name(pn)
      promotion = Promotion.create(:name=>pn, :is_outbound=>out, :from_code=>from) if promotion.nil?
      self.promotion_id = promotion.id
    end

    
  end

  validate(:on => :update) do
    errors.add(:test_password, "est incorrect") unless self.forced or Person.authenticate(self.user_name, self.test_password) # self.confirm(self.test_password)
  end

  validate do
    errors.add(:password, "ne peut être vide") if self.hashed_password.blank?
    if self.proposer_zone and self.host_zone and self.student
      errors.add_to_base("Le club d'origine et le club hôte ne peuvent pas être tous les deux en France") if self.proposer_zone.country.iso3166.lower == 'fr' and self.host_zone.country.iso3166.lower == 'fr'
      errors.add_to_base("Le club d'origine et le club hôte ne peuvent pas être tous les deux à l'étranger") if self.proposer_zone.country.iso3166.lower != 'fr' and self.host_zone.country.iso3166.lower != 'fr'
    end

  end
  
  after_save do
    PersonVersion.create!(self.attributes.merge(:person_id=>self.id))
  end

  before_destroy do
    total = 0
    # MandateNature.find(:all,:conditions=>"' '||rights||' ' ilike '% all %'").each{|x| total+=x.people.size}
    raise Exception.new("Vous ne pouvez pas supprimer un administrateur dans l'exercice de sa fonction") if self.rights.include? :all
    if self.subscriptions.size<=0
      # PersonVersion.delete_all(:person_id=>self.id)
      self.articles = {}
      # self.emails   = {}
      self.images   = {}
      self.mandates = {}
      self.members  = {}
      self.periods  = {}
      self.versions = {}      
    end
    self.periods.each do |p|
      p.destroy
    end
  end

  def password
    @password
  end

  def password=(password)
    @password=password
    unless password.blank?
      self.salt=self.object_id.to_s[1..16] + rand.to_s[2..16]
      self.hashed_password=Person.encrypt(@password, self.salt)
    end
  end

  def rights(active_on=Date.today)
    array = []
    for mandate in self.mandates.find(:all, :conditions=>["dont_expire OR ? BETWEEN begun_on AND COALESCE(finished_on, CURRENT_DATE)", active_on])
      array += mandate.nature.rights_array
    end
    return array.uniq
  end

  def self.mandated_for(nature, active_on=Date.today)
    nature = [nature] unless nature.is_a? Array
#    nature = '('+nature.collect do |n|
#      "'"+(nature.is_a?(MandateNature) ? nature.id : MandateNature.find_by_code(nature).id).to_s+"'"
#    end.join(',')+')'
#    pids = Mandate.find(:all, :conditions=>["(dont_expire OR ? BETWEEN begun_on AND COALESCE(finished_on, CURRENT_DATE)) AND nature_id IN "+nature, active_on]).collect{|m| m.person_id}
    pids = Mandate.find(:all, :joins=>"JOIN mandate_natures mn ON (mn.id=nature_id)", :conditions=>["(dont_expire OR ? BETWEEN begun_on AND COALESCE(finished_on, CURRENT_DATE)) AND mn.code IN (?)", active_on, nature]).collect{|m| m.person_id}
    Person.find(:all, :conditions=>{:id=>pids})
  end

  def mandate(nature, active_on=Date.today)
    self.mandates.find(:first, :joins=>"JOIN mandate_natures mn ON (mn.id=nature_id)", :conditions=>["(dont_expire OR ? BETWEEN begun_on AND COALESCE(finished_on, CURRENT_DATE)) AND code=?", active_on, nature], :order=>:begun_on)
  end
  
  def questions
    Question.find(:all, :conditions=>["id IN (SELECT question_id FROM answers WHERE person_id=?) OR (CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE+'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE+'1 day'::INTERVAL) AND promotion_id=?)", self.id, self.promotion_id])
  end


  def change_password
    pwd = Person.generate_password
    self.forced = true
    self.password = pwd
    self.password_confirmation = pwd
    self.save
    pwd
  end

  def self.authenticate(name,password)
    person = self.find(:first, :conditions=>{:user_name=>name})
    if person
      # person = nil if person.is_locked or !person.confirm(password) or !(person.rights.include?(:all) or person.has_subscribed_on?)
      person = nil if person.is_locked or not person.confirm(password)
    end
    person
  end


  def admin?
    self.rights.include?(:all)
  end
  
  def label
    patro = ''
    patro += ' (né(e) '+self.patronymic_name+')' if self.family_name!=self.patronymic_name
    self.first_name+' '+self.family_name
  end

  def title
    self.family_name+" "+self.first_name
  end


  def hashed_salt
    self.class.encrypt(self.salt, self.salt)
  end

  def approve!
    unless self.approved
      Maily.deliver_approval(self)
    end
    self.update_attribute(:approved, true)
    self.update_attribute(:is_locked, false)
  end

  def disapprove!
    self.update_attribute(:approved, true)
    self.update_attribute(:is_locked, true)
    self.update_attribute(:comment, "Verrouillée car inconnue au sein de l'association")
  end

  def story?
    self.articles.find(:all, :conditions=>["status=? AND rubric_id= ? AND done_on IS NOT NULL", 'P', Configuration.parameter(:news_rubric_id)]).size>0
  end

  def confirm(password)
    return (self.hashed_password == Person.encrypt(password.to_s, self.salt) ? true : false )
  end

  def has_subscribed_on?(verified_on=Date.today)
    Subscription.count(:joins=>"LEFT JOIN sales ON (sale_id=sales.id)", :conditions=>["person_id=? AND (state=? OR state IS NULL) AND ? BETWEEN begun_on AND finished_on", self.id, "P", verified_on])>0
  end

  def has_subscribed?(delay=2.months)
    # Subscription.count(:conditions=>["person_id=? AND finished_on>=CAST(? AS DATE)", self.id, Date.today-delay])>0
    self.has_subscribed_on?(Date.today+delay)
  end

  def first_day_as_non_subscriber
    max = Date.today-1
    if sub = self.subscriptions.find(:first, :conditions=>{:state=>'P'}, :order=>"finished_on DESC")
      max = sub.finished_on if sub.finished_on>max
    end
    return max+1
  end

  def reports
    self.articles.find(:all, :conditions=>{:rubric_id=>Configuration.the_one.news_rubric_id}, :order=>"done_on")
  end

  def current?
    (self.started_on||Date.today) <= Date.today and Date.today <= (self.stopped_on||Date.today)
  end

  def in_zone?(zone)
    if self.promotion
      return true if self.proposer_zone.in_zone?(zone) or self.host_zone.in_zone?(zone)
    end
    return false
  end

  def a_locked
    "Verrouillée"
  end

  def a_ready
    "Prête"
  end

  def a_writing
    "À l'écriture"
  end
  
  def state_for(question_id)
    if answer = Answer.find_by_question_id_and_person_id(question_id, self.id)
      return answer.status.to_sym
    else
      return :empty
    end
  end


  def self.generate_password(length=8)
    l = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W Y X Z 0 1 2 3 4 5 6 7 8 9)
    s = l.length
    c = ''
    length=1 if length<1
    for x in 1..length
      c += l[(s*rand).to_i]
    end
    c
  end

  private

  def self.encrypt(password, salt)
    Digest::SHA256.hexdigest('<'+salt+':'+password+password+'/>')
  end 

end
