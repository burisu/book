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
  validates_confirmation_of :password

  def before_validation
    self.user_name.gsub!(/(-|\.)/,'').downcase!
    self.rotex_email = self.user_name+'@rotex1690.org'
 #   self.first_name.capitalize!
 #   self.second_name.capitalize!
 #   self.patronymic_name.upcase!
 #   self.family_name.upcase!
  end

  def validate
    error.add_to_base("Mot de passe manquant") if hashed_password.blank?
  end

  def password
    @password
  end

  def password=(password)
    @password=password
    self.salt=self.object_id.to_s[1..16] + rand.to_s[2..16]
    self.hashed_password=Person.encrypt(self.password,self.salt)
  end
  
  def can_create_persons?
    self.role.restriction_level<1000
  end

  def self.authenticate(name,password)
    personne = self.find_by_user_name name
    if personne
      if personne.is_locked
	 personne = nil
      else
        pwd=Person.encrypt(password,personne.salt)
	personne = nil if pwd != personne.hashed_password
      end
    end
    personne
  end

private
  def self.encrypt(password,salt)
    Digest::MD5.hexdigest(password+'password'+salt+password)
  end
end
