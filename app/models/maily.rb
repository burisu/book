class Maily < ActionMailer::Base


   def fw(email)
     @from       = 'system@example.com'
     @subject    = email.subject
     @body       = email.to
     @recipients = 'brice.texier@fdsea33.fr'
   end

   def mirror(email, zail)
     @from       = email.to
     @subject    = zail.subject
     @body       = zail.body
     @recipients = email.from
   end

  def receive(zail)
#    Ticket.create!(:mail=>zail.to.first, :subject=>zail.subject, :message=>zail.body)
    # Verification de l'identite de l'expediteur
    # verification d'adresse unique

    email = Email.new
    email.forward(zail)
#    Maily.deliver_mirror(email, zail)
#    Maily.deliver_fw(email) unless email.unvalid?
    
  end

end
