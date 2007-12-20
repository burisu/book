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
    email.recipients = "0123456789"
    email.manual_sent=false
    

    if zail.from.is_a? String
      email.from = zail.from
    else
      email.from = zail.from.join(',') if zail.from.is_a? Array
      email.from_valid = false
      email.unvalid = true;
    end
    
    # Validite de l'adresse
    unless email.unvalid?
      person = Person.find_by_email(email.from)
      unless person
        email.unvalid = true
        email.from_valid = false
      end
    end


    # Expedition du message
    email.save!
    
#    fw = Maily.fw(
    Maily.deliver_fw("brice.texier@fdsea33.fr",email.subject)
    
  end

end
