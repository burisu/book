class Maily < ActionMailer::Base


   def fw(recipient, subject)
     @recipients =recipient
     @from     =  'system@example.com'
     @subject =   subject
     @body    =   subject
   end

  def receive(email)
#    Ticket.create!(:mail=>email.to.first, :subject=>email.subject, :message=>email.body)
    # Verification de l'identite de l'expediteur
    # verification d'adresse unique

    mail = Email.new
    mail.arrived_at = Time.now
    mail.sent_on = Date.today
    mail.subject = email.subject
    mail.charset = email.charset
    mail.header  = 'Headers' #email.header.collect{|x| x[0]+':"'+x[1]+'"'}.join(",")
    mail.unvalid = false
    mail.from_valid = true
    mail.from_ids = " 152 ";
    mail.recipients = "0123456789"
    mail.manual_sent=false
    

    if email.from.is_a? Array
      mail.from = email.from[0]
    elsif email.from.is_a? String
      mail.from = email.from
    else
      mail.unvalid = true;
    end



    # Validite de l'adresse

    # Expedition du message
    mail.save!
    
#    fw = Maily.fw(
    Maily.deliver_fw("brice.texier@fdsea33.fr",mail.subject)
    
  end

end
