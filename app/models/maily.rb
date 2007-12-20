class Maily < ActionMailer::Base


   def fw(recipient, subject)
     @recipients =recipient
     @from     =  'system@example.com'
     @subject =   subject
     @body    =   subject
   end

  def receive(zail)
#    Ticket.create!(:mail=>zail.to.first, :subject=>zail.subject, :message=>zail.body)
    # Verification de l'identite de l'expediteur
    # verification d'adresse unique

    email = Email.new
    email.arrived_at = Time.now
    email.sent_on = Date.today
    email.subject = zail.subject
    email.charset = zail.charset
    email.header  = 'Headers' #zail.header.collect{|x| x[0]+':"'+x[1]+'"'}.join(",")
    email.unvalid = false
    email.from_valid = true
    email.from_id = " 152 ";
    email.manual_sent=false
    

    if zail.from.is_a? String
      email.from = zail.from
    else
      email.from = zail.from.join(',') if zail.from.is_a? Array
      email.from_valid = false
      email.unvalid = true;
    end
    
    # Validite de l'adresse de l'expediteur
    unless email.unvalid?
      person = Person.find_by_email(email.from)
      unless person
        email.unvalid = true
        email.from_valid = false
      else
        email.from_id = person.id
      end
    end

    # Validite de l'adresse de destination
    emails = []
    if zail.recipients.is_a? String 
      email.recipients = zail.recipients
      emails << emails.recipients
    elsif zail.recipients.is_a? Array
      for x in zail.recipients
        if x.match('.*<.*>')
          emails << x.gsub(/.*</,'').gsub(/>.*/,'').strip
        else
          emails << x
        end
      end
    else
      email.unvalid = true
    end
      
    email.recipients = "0123456789"


    # Expedition du message
    email.save!
    
#    fw = Maily.fw(
    Maily.deliver_fw("brice.texier@fdsea33.fr",email.subject) unless email.unvalid?
    
  end

end
