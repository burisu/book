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
  def initialize(*params)
    super(*params)
    zail = params[0]
    self.arrived_at = Time.now
    self.sent_on = Date.today
    self.subject = zail.subject
    self.charset = zail.charset
    self.header  = 'Headers' #zail.header.collect{|x| x[0]+':"'+x[1]+'"'}.join(",")
    self.unvalid = false
    self.from_valid = true
    self.from_id = " 152 ";
    self.manual_sent=false
    

    if zail.from.is_a? String
      self.from = zail.from
    else
      self.from = zail.from.join(',') if zail.from.is_a? Array
      self.from_valid = false
      self.unvalid = true;
    end
    
    # Validite de l'adresse de l'expediteur
    unless self.unvalid?
      person = Person.find_by_self(self.from)
      unless person
        self.unvalid = true
        self.from_valid = false
      else
        self.from_id = person.id
      end
    end

    # Validite de l'adresse de destination
    selfs = []
    if zail.recipients.is_a? String 
      self.recipients = zail.recipients
      selfs << selfs.recipients
    elsif zail.recipients.is_a? Array
      for x in zail.recipients
        if x.match('.*<.*>')
          selfs << x.gsub(/.*</,'').gsub(/>.*/,'').strip
        else
          selfs << x
        end
      end
    else
      self.unvalid = true
    end
      
    self.recipients = "0123456789"

  
  end

end
