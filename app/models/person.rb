# == Schema Information
# Schema version: 20090529124009
#
# Table name: people
#
#  id                :integer         not null, primary key
#  patronymic_name   :string(255)     not null
#  family_name       :string(255)     not null
#  family_id         :integer         
#  first_name        :string(255)     not null
#  second_name       :string(255)     
#  user_name         :string(32)      not null
#  photo             :string(255)     
#  country_id        :integer         not null
#  sex               :string(1)       not null
#  born_on           :date            not null
#  address           :text            not null
#  latitude          :float           
#  longitude         :float           
#  phone             :string(32)      
#  phone2            :string(32)      
#  fax               :string(32)      
#  mobile            :string(32)      
#  email             :string(255)     not null
#  replacement_email :string(255)     
#  hashed_password   :string(255)     
#  salt              :string(255)     
#  rotex_email       :string(255)     
#  validation        :string(255)     
#  is_validated      :boolean         not null
#  is_locked         :boolean         not null
#  is_user           :boolean         not null
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  lock_version      :integer         default(0), not null
#

require 'digest/sha2'

class Person < ActiveRecord::Base
  attr_accessor :password_confirmation
  attr_accessor :test_password
  attr_accessor :terms_of_use
  attr_accessor :forced
  attr_protected :email, :replacement_email, :is_locked, :is_validated, :validation, :salt, :hashed_password, :forced, :is_user
  validates_confirmation_of :password
  validates_uniqueness_of :email #, :if=>Proc.new {|p| !p.system }
  validates_length_of :user_name, :in=>4..32
  validates_acceptance_of :terms_of_use
  apply_simple_captcha :message => "Le texte est différent de l'image de vérification", :add_to_base => true

  def before_validation
    self.patronymic_name = self.patronymic_name.to_s.upcase
    self.family_name = self.family_name.to_s.upcase
    self.family_name = self.patronymic_name if self.family_name.blank?
    self.forced = false if self.forced.nil?
    self.user_name.gsub!(/(-|\.|\ )/,'')
    self.rotex_email = self.user_name.lower_ascii+'@rotex1690.org'
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
    
  end

  def validate_on_update
    errors.add(:test_password, "est incorrect") unless self.forced or self.confirm(self.test_password)
  end

  def validate
    errors.add(:password, "ne peut être vide") if self.hashed_password.blank?
  end
  
  def before_save
    self.rotex_email = self.user_name+'@rotex1690.org'
  end

  def after_save
    PersonVersion.create!(self.attributes.merge(:person_id=>self.id))
  end

  def before_destroy
    total = 0
    # MandateNature.find(:all,:conditions=>"' '||rights||' ' ilike '% all %'").each{|x| total+=x.people.size}
    raise Exception.new("Vous ne pouvez pas supprimer un administrateur dans l'exercice de sa fonction") if self.can_manage?
    if self.subscriptions.size<=0
      # PersonVersion.delete_all(:person_id=>self.id)
      self.articles = {}
      self.emails   = {}
      self.folders  = {}
      self.images   = {}
      self.mandates = {}
      self.members  = {}
      self.periods  = {}
      self.versions = {}      
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
  
  def can_manage?(level=:all,mode=:or)
    if level.is_a? Symbol
      return self.role.can_manage?(level)
    elsif level.is_a? Array
      ok = false
      if mode==:and
        ok = true
        level.each{|x| ok = false unless self.role.can_manage?(x)}
      else
        level.each{|x| ok = true if self.role.can_manage?(x)}
      end
      return ok
    else
      raise Exception.new "Bad type for right: "+level.class.to_s
    end
  end

  def can_read?(article)
    article = Article.find(article) unless article.is_a? Article
    (article.author_id == self.id) or self.can_manage? :all or self.can_manage? :publishing
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
    person = self.find_by_user_name name
    if person
      person = nil if person.is_locked or !person.confirm(password) or !(person.can_manage?(:all) or person.has_subscribed?)
    end
    person
  end
  
  def label
    self.first_name+' '+self.family_name
  end

  def confirm(password)
    return (self.hashed_password == Person.encrypt(password.to_s, self.salt) ? true : false )
  end

  def has_subscribed_on?(date=Date.today)
    Subscription.count(:conditions=>["person_id=? AND ? BETWEEN begun_on AND finished_on",self.id,date])>0
  end

  def has_subscribed?(delay=2.months)
    Subscription.count(:conditions=>["person_id=? AND finished_on>=?::DATE",self.id,Time.now-delay])>0
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
