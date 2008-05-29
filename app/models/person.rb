# == Schema Information
# Schema version: 4
#
# Table name: people
#
#  id               :integer       not null, primary key
#  patronymic_name  :string(255)   not null
#  family_name      :string(255)   
#  first_name       :string(255)   not null
#  second_name      :string(255)   
#  is_female        :boolean       default(true), not null
#  born_on          :date          not null
#  home_address     :text          not null
#  aligned_to_right :boolean       not null
#  home_phone       :string(32)    
#  work_phone       :string(32)    
#  fax              :string(32)    
#  mobile           :string(32)    
#  messenger_email  :string(255)   
#  user_name        :string(32)    not null
#  email            :string(255)   not null
#  hashed_password  :string(255)   not null
#  salt             :string(255)   not null
#  rotex_email      :string(255)   
#  is_locked        :boolean       not null
#  photo            :string(255)   
#  country_id       :integer       not null
#  role_id          :integer       not null
#  created_at       :datetime      not null
#  updated_at       :datetime      not null
#  lock_version     :integer       default(0), not null
#

class Person < ActiveRecord::Base
  attr_accessor :password_confirmation
  attr_accessor :test_password
  attr_accessor :terms_of_use
  attr_accessor :forced
  attr_protected :email, :replacement_email, :is_locked, :is_validated, :validation, :salt, :hashed_password, :forced
  validates_confirmation_of :password
  validates_uniqueness_of :email, :if=>Proc.new {|p| !p.system }
  validates_length_of :user_name, :in=>4..32
  validates_acceptance_of :terms_of_use
  apply_simple_captcha :message => "Le texte est différent de l'image de vérification", :add_to_base => true

  def before_validation
    if self.user_name=='rotadmin'
      self.patronymic_name = 'ADMIN'
      self.first_name   = 'Rot'
      self.born_on      = Date.civil(2007,11,26)
      self.home_address = 'Rotex 1690 France'
      self.user_name    = 'rotadmin'
      self.email        = 'brice.texier@oneiros.fr'
      self.is_validated = true
      self.is_locked    = false
      self.password     = 'r0t4dm|n'
      self.password_confirmation = 'r0t4dm|n'
      language = Language.find_by_iso639('FR')
      language = Language.create(:name=>'Français', :native_name=>'Français', :iso639=>'FR') if language.nil?
      country  = Country.find_by_iso3166('FR')
      self.country      = country.nil? ? Country.create(:name=>'France', :iso3166=>'FR', :language=>language) : country
      role =  Role.find_by_name('admin')
      self.role         = role.nil? ? Role.create(:name=>'admin', :restriction_level=>0) : role
    end
    self.forced = false if self.forced.nil?
    self.user_name.gsub!(/(-|\.)/,'')
    self.rotex_email = rand.to_s[2..16]
    self.validation = Person.generate_password(73+2*(10*rand).to_i) unless self.is_validated or !self.replacement_email.blank?
#   self.first_name.capitalize!
#   self.second_name.capitalize!
#   self.patronymic_name.upcase!
#   self.family_name.upcase!
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

  def password
    @password
  end

  def password=(password)
    @password=password
    if password!=''
      self.salt=self.object_id.to_s[1..16] + rand.to_s[2..16]
      self.hashed_password=Person.encrypt(self.password,self.salt)
    end
  end
  
  def can_create_persons?
    self.role.restriction_level<1000
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
    personne = self.find_by_user_name name
    if personne
      personne = nil if personne.is_locked or !personne.confirm(password)
    end
    personne
  end
  
  def label
    self.first_name+' '+self.patronymic_name
  end

  def confirm(password)
    return self.hashed_password==Person.encrypt(password.to_s, self.salt)
  end

  private

  def self.encrypt(password,salt)
    Digest::MD5.hexdigest('<'+salt+':'+password+password+'/>')
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
  
end
