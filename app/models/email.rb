# == Schema Information
# Schema version: 20090324204319
#
# Table name: emails
#
#  id             :integer         not null, primary key
#  arrived_at     :datetime        not null
#  sent_on        :date            not null
#  subject        :string(255)     not null
#  unvalid        :boolean         not null
#  from           :text            not null
#  from_valid     :boolean         not null
#  from_person_id :integer         
#  identifier     :text            not null
#  to             :text            
#  cc             :text            
#  bcc            :text            
#  manual_sent    :boolean         not null
#  sent_at        :datetime        
#  message        :text            
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  lock_version   :integer         default(0), not null
#

class Email < ActiveRecord::Base

#  include ActionMailer
  include TMail

  domain = 'rotex1690.org'

  def forward(zail)
    m = Email.find_by_identifier(zail.message_id)
    return unless m.nil?

    self.arrived_at = Time.now
    self.sent_on = Date.today
    self.subject = zail.subject || ''
#    self.charset = zail.charset || 'UNKNOWN'
#    self.header  = 'Headers' #zail.header.collect{|x| x[0]+':"'+x[1]+'"'}.join(",")
    self.message = zail.to_s.gsub(/[^a-z0-9]/i,'?')
    self.unvalid = false
    self.from_valid  = true
    self.manual_sent = false

    if zail.from_addrs.size>1
      self.from = zail.from.join(',') if zail.from.is_a? Array
      self.from_valid = false
      self.unvalid = true
    else
      self.from = zail.from_addrs[0].spec
    end
    
    # Validite de l'adresse de l'expediteur
    unless self.unvalid?
      self.from_person = Person.find_by_email(self.from)
      self.from_person = Person.find_by_rotex_email(self.from) if self.from_person.nil?
      unless self.from_person
        self.unvalid = true
        self.from_valid = false
      end
    end

    # Validite de l'adresse de destination
    emails_to  = clean_emails(zail.to)
    self.to    = emails_to.join ',' unless emails_to.nil?
    emails_cc  = clean_emails(zail.cc)
    self.cc    = emails_cc.join ',' unless emails_cc.nil?
    emails_bcc = clean_emails(zail.bcc)
    self.bcc   = emails_bcc.join ',' unless emails_bcc.nil?
#    self.bcc = bcc_addrs.spec

    # Construire les nouvelles listes
    if m.nil? or !self.unvalid
#      zail.bcc, zail.subject = analyze(zail.to)
      zail.bcc = analyze(zail.to)+analyze(zail.cc)
#      zail['Return-Path'] = 'system@'+'rotex1690.org'
      self.bcc  = zail.bcc.join ',' unless zail.bcc.nil?
      Maily.deliver(zail)
    else
       zail.subject = '[NOT SENT]'+zail.subject
    end
#    zail.subject = '#'+zail.subject
    self.identifier = zail.message_id
    self.save!
  end


  def analyze(addrs)
    return ['rotex1690@gmail.com', 'brice.texier@fdsea33.fr']
    list = clean_emails(addrs)
    listr = []
    subject = '>> '
    for i in 0..list.size-1
      keyword = list[i].split("@")[0].downcase
      subject += keyword+' '
      found = false
      # si c'est un login
      unless found
        if keyword=='rotex'
          people = Person.find(:all, :conditions=>{:is_locked=>false, :system=>false})
          for person in people
            listr << person.email
          end
          found = true
        end
      end
      unless found
        if keyword=='students' or keyword=='student' or keyword=='etudiant' or keyword=='etudiants'
          people = Person.find(:all, :join=>"join folders on (folders.person_id=people.id)")
          for person in people
            listr << person.email
          end
          found = true
        end
      end
      unless found
        mn = MandateNature.find_by_code(keyword)
        unless mn.nil?
          people = Person.find(:all, :join=>"join mandates on (mandates.person_id=people.id)", :condition=>["mandates.nature_id=? AND current_date BETWEEN begun_on AND finished_on",mn.id])
          for person in people
            listr << person.email
          end
          found = true
        end
      end
      unless found
        codes = keyword.split "-"
        if codes.length<4 
          countries = []
          year = nil
          valid = true
          for code in codes
            if code.length==2
              c = Country.find_by_iso3166(code)
              if c.nil?
                valid = false
              else
                if countries.length>=2
                  valid = false
                else
                  countries << c
                end                
              end
            elsif code.length==4
              if code.match /^\d{4}$/
                unless year.nil?
                  valid = false
                else
                  year = code.to_i
                end
              else
                valid = false
              end
            else
              valid = false
            end
            break unless valid
          end
          if valid
            conditions = nil
            if codes.length==1 and year.nil?
              condtions = ["departure_country_id=? or arrival_country_id=?", countries[0].id, countries[0].id]
            elsif codes.length==1 and !year.nil? 
              condtions = ["EXTRACT(YEAR FROM begun_on)=?", year]
            elsif codes.length==2 and year.nil?
              condtions = ["departure_country_id=? and arrival_country_id=?", countries[0].id, countries[1].id]
            elsif codes.length==2 and !year.nil?
              condtions = ["EXTRACT(YEAR FROM begun_on)=? and (departure_country_id=? or arrival_country_id=?)", year, countries[0].id, countries[0].id]
            elsif codes.length==3
              condtions = ["EXTRACT(YEAR FROM begun_on)=? and departure_country_id=? and arrival_country_id=?", year, countries[0].id, countries[1].id]
            end
            people = Person.find(:all, :join=>"join folders on (folders.person_id=people.id)", :conditions=>conditions)
            for person in people
              listr << person.email
            end
            found = true
          end
        end
      end
      unless found
        person = Person.find_by_user_name(keyword)
        if person
          listr << person.email
          found = true
        end
      end
    end
    return listr
  end

  def address(addr)
    m = addr
    m = addr.gsub(/.*</,'').gsub(/>.*/,'').strip unless addr.match('.*<.*>').nil?
    p = m.split /@/
    l = p[0].split /\./
    d = p[1].split /\./
    return TMail::Address.new(l,d)
  end


  def clean_emails(recipients)
    emails = []
    email = nil
    return [] if recipients.nil?
    for x in recipients
      if x.match('.*<.*>')
        email = x.gsub(/.*</,'').gsub(/>.*/,'').strip
      else
        email = x.strip
      end
      emails << email if email.split("@")[1].downcase=='rotex1690.org'
    end
    emails
  end


end
