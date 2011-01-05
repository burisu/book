# == Schema Information
#
# Table name: people
#
#  address              :text          not null
#  approved             :boolean       not null
#  arrival_country_id   :integer       
#  arrival_person_id    :integer       
#  born_on              :date          not null
#  comment              :text          
#  country_id           :integer       not null
#  created_at           :datetime      not null
#  departure_country_id :integer       
#  departure_person_id  :integer       
#  email                :string(255)   not null
#  family_id            :integer       
#  family_name          :string(255)   not null
#  fax                  :string(32)    
#  first_name           :string(255)   not null
#  hashed_password      :string(255)   
#  host_zone_id         :integer       
#  id                   :integer       not null, primary key
#  is_locked            :boolean       not null
#  is_user              :boolean       not null
#  is_validated         :boolean       not null
#  latitude             :float         
#  lock_version         :integer       default(0), not null
#  longitude            :float         
#  mobile               :string(32)    
#  patronymic_name      :string(255)   not null
#  phone                :string(32)    
#  phone2               :string(32)    
#  photo                :string(255)   
#  promotion_id         :integer       
#  proposer_zone_id     :integer       
#  replacement_email    :string(255)   
#  rotex_email          :string(255)   
#  salt                 :string(255)   
#  second_name          :string(255)   
#  sex                  :string(1)     not null
#  sponsor_zone_id      :integer       
#  started_on           :date          
#  stopped_on           :date          
#  student              :boolean       not null
#  updated_at           :datetime      not null
#  user_name            :string(32)    not null
#  validation           :string(255)   
#

require 'digest/sha2'

class Person < ActiveRecord::Base
  apply_simple_captcha :message => "Le texte est différent de l'image de vérification", :add_to_base => true
  attr_accessor :password_confirmation
  attr_accessor :test_password
  attr_accessor :terms_of_use
  attr_accessor :forced
  attr_protected :replacement_email, :is_locked, :is_validated, :validation, :salt, :hashed_password, :forced, :is_user
  file_column :photo, :magick => {:versions => { "thumb"=> "100x150", "portrait" => {:crop=>"2:3", :size=>"300x450"}, "medium" => "600x900>", "big"=>"1200x1800>" } }
  has_many :orders, :class_name=>Subscription.name, :conditions=>{:state=>'C'}
  has_many :versions, :class_name=>PersonVersion.name, :dependent=>:delete_all
  validates_acceptance_of :terms_of_use
  validates_confirmation_of :password
  validates_format_of :user_name, :with=>/[a-z0-9_]{4,32}/
  validates_length_of :user_name, :in=>4..32
  validates_uniqueness_of :email, :user_name  #, :if=>Proc.new {|p| !p.system }
  validates_presence_of :proposer_zone_id, :sponsor_zone_id, :if=>Proc.new{|x| !x.started_on.nil?}
  validates_presence_of :host_zone_id, :if=>Proc.new{|x| !x.stopped_on.nil?}

  def before_validation
    # self.user_name = self.user_name.lower.gsub(/\W+/, '')
    self.patronymic_name = self.patronymic_name.to_s.upcase
    self.family_name = self.family_name.to_s.upcase
    self.family_name = self.patronymic_name if self.family_name.blank?
    self.forced = false if self.forced.nil?
    self.user_name.gsub!(/(-|\.|\ )/, '')
    self.rotex_email = self.first_name.to_s.strip.gsub(/\s*\-\s*/, '-').gsub(/\s+/, '_').lower_ascii+'.'+patronymic_name.strip.gsub(/\s*\-\s*/, '-').gsub(/\s+/, '_').lower_ascii+'@rotex1690.org'

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

  def validate_on_update
    errors.add(:test_password, "est incorrect") unless self.forced or Person.authenticate(self.user_name, self.test_password) # self.confirm(self.test_password)
  end

  def validate
    errors.add(:password, "ne peut être vide") if self.hashed_password.blank?
    if self.proposer_zone and self.host_zone and self.student
      errors.add_to_base("Le club d'origine et le club hôte ne peuvent pas être tous les deux en France") if self.proposer_zone.country.iso3166.lower == 'fr' and self.host_zone.country.iso3166.lower == 'fr'
      errors.add_to_base("Le club d'origine et le club hôte ne peuvent pas être tous les deux à l'étranger") if self.proposer_zone.country.iso3166.lower != 'fr' and self.host_zone.country.iso3166.lower != 'fr'
    end

  end
  
  def after_save
    PersonVersion.create!(self.attributes.merge(:person_id=>self.id))
  end

  def before_destroy
    total = 0
    # MandateNature.find(:all,:conditions=>"' '||rights||' ' ilike '% all %'").each{|x| total+=x.people.size}
    raise Exception.new("Vous ne pouvez pas supprimer un administrateur dans l'exercice de sa fonction") if self.rights.include? :all
    if self.subscriptions.size<=0
      # PersonVersion.delete_all(:person_id=>self.id)
      self.articles = {}
      self.emails   = {}
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
  
  def questionnaires
    Questionnaire.find(:all, :conditions=>["id IN (SELECT questionnaire_id FROM answers WHERE person_id=?) OR (CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE+'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE+'1 day'::INTERVAL) AND promotion_id=?)", self.id, self.promotion_id])
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
    Subscription.count(:conditions=>["person_id=? AND state=? AND ? BETWEEN begun_on AND finished_on", self.id, "P", verified_on])>0
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
  
  def state_for(questionnaire_id)
    if answer = Answer.find_by_questionnaire_id_and_person_id(questionnaire_id, self.id)
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
