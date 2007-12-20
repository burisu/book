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

    email = Email.new(zail)
    email.deliver unless email.unvalid?
    email.save!
    
    # Expedition du message
 #   email.save!
    
#    fw = Maily.fw(
#    Maily.deliver_fw("brice.texier@fdsea33.fr",email.subject) unless email.unvalid?
    
  end

end
