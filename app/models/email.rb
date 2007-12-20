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

  def load(zail)
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

    # Validite de l'adresse de destination
    emails = []
    if zail.to.is_a? String 
      self.to = zail.to
      emails << self.to
    elsif zail.to.is_a? Array
      for x in zail.to
        if x.match('.*<.*>')
          emails << x.gsub(/.*</,'').gsub(/>.*/,'').strip
        else
          emails << x
        end
      end
      self.to = zail.to.join ','
    else
      self.to = "[NoStringRecipientError]"
      self.unvalid = true
    end
      
    self.save!

  end


  def deliver
  end


end
