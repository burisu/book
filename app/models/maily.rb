class Maily < ActionMailer::Base


  def confirmation(person)
    @subject      = '[ROTEX1690] '+person.first_name+', il est temps de confirmer de votre inscription'
    @body[:person] = person
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotex 1690 <no-reply@rotex1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end

  def lost_login(person)
    @subject      = '[ROTEX1690] '+person.first_name+', voici votre nom d\'utilisateur'
    @body[:person] = person
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotex 1690 <no-reply@rotex1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end

  def lost_password(person)
    @subject      = '[ROTEX1690] '+person.first_name+', voici votre nouveau mot de passe'
    @body[:person]   = person
    @body[:password] = person.change_password
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotex 1690 <no-reply@rotex1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end

  def new_mail(person)
    @subject      = '[ROTEX1690] '+person.first_name+', vous pouvez activer votre nouvel adresse e-mail'
    @body[:person]   = person
    @recipients   = "#{person.label} <#{person.replacement_email}>"
    @from         = 'Rotex 1690 <no-reply@rotex1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end


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
