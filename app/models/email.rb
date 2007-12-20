# == Schema Information
# Schema version: 4
#
# Table name: emails
#
#  id             :integer       not null, primary key
#  arrived_at     :datetime      not null
#  send_on        :date          not null
#  subject        :string(255)   not null
#  charset        :string(255)   not null
#  header         :text          not null
#  unvalid        :boolean       not null
#  from           :text          not null
#  from_valid     :boolean       not null
#  from_ids       :text          not null
#  recipients     :text          not null
#  cc             :text          
#  bcc            :text          
#  receivers_good :text          
#  receivers_bad  :text          
#  receivers_ids  :text          
#  manual_sent    :boolean       not null
#  sent_at        :datetime      
#  created_at     :datetime      not null
#  updated_at     :datetime      not null
#  lock_version   :integer       default(0), not null
#

class Email < ActiveRecord::Base

#  include ActionMailer
  include TMail

  def forward(zail)
    self.arrived_at = Time.now
    self.sent_on = Date.today
    self.subject = zail.subject || ''
    self.charset = zail.charset || 'UNKNOWN'
    self.header  = 'Headers' #zail.header.collect{|x| x[0]+':"'+x[1]+'"'}.join(",")
    self.unvalid = false
    self.from_valid  = true
    self.manual_sent = false
    
    if zail.from.is_a? String
      self.from = zail.from
    else
      self.from = zail.from.join(',') if zail.from.is_a? Array
      self.from_valid = false
      self.unvalid = true;
    end
    
    # Validite de l'adresse de l'expediteur
    unless self.unvalid?
      self.from_person = Person.find_by_self(self.from)
      unless self.from_person
#        self.unvalid = true
        self.from_valid = false
      end
    end

#    sail = TMail::Mail.setup_forward(zail)
#    sail = TMail::Mail.create_empty_mail

    # Validite de l'adresse de destination
    emails_to  = clean_emails(zail.to)
    self.to    = emails_to.join ',' unless emails_to.nil?
    emails_cc  = clean_emails(zail.cc)
    self.cc    = emails_cc.join ',' unless emails_cc.nil?
    emails_bcc = clean_emails(zail.bcc)
    self.bcc   = emails_bcc.join ',' unless emails_bcc.nil?
#    self.bcc = bcc_addrs.spec

    # Construire les nouvelles listes
    for x in zail.to_addrs
      sail = TMail::Mail.new
      sail.to_addrs = analyze(x.spec)
      Maily.deliver(sail)
    end

    self.save!
  end


  def analyze(addr)
    list = []
    list << 'brice.texier@fdsea33.fr'
    list << 'informatique@fdsea33.fr'
    list << 'brice@fdsea33.fr'
    group = TMail::AddressGroup.new(addr,[])
    for i in 0..list.size-1
      group.push(address(list[i]))
    end
    return group
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
    return if recipients.nil?
    for x in recipients
      if x.match('.*<.*>')
        emails << x.gsub(/.*</,'').gsub(/>.*/,'').strip
      else
        emails << x
      end
    end
    emails
  end


end
