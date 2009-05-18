class Maily < ActionMailer::Base


  def confirmation(person)
    @subject      = '[ROTEX1690] '+person.first_name+', il est temps de confirmer de votre inscription'
    @body[:person] = person
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotex 1690 <no-reply@rotex1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end
  
  def notification(nature=:subscription, person=nil)
    @subject      = '[ROTEX1690] Notification : '+
      if nature==:subscription
        "Enregistrement d'un nouveau membre (#{person.label})"
      elsif nature==:activation
        "Activation de compte (#{person.label})"
      else
        "Inconnue"
      end
    @body[:nature] = nature
    @body[:person] = person
    roles = Role.find(:all, :conditions=>["code in (?, ?)", 'tresor', 'admin']).collect{|r| r.id}
    people = Person.find(:all, :conditions=>{:role_id=>roles})
    @recipients   = people.collect{|person| "#{person.label} <#{person.email}>"} # .join (', ')
    @from         = 'Rotex 1690 <no-reply@rotex1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end
  
  def message(person, options={})
    @subject      = '[ROTEX1690] '+options[:subject].to_s
    @body[:body] = options[:body].to_s
    country = Country.find(options[:arrival_id])
    promotion = Promotion.find(options[:promotion_id])
    people = Folder.find(:all, :conditions=>{:arrival_country_id=>country.id, :promotion_id=>promotion.id}).collect{|f| f.person}
    @recipients   = "#{country.name.to_s+' '+promotion.name.to_s} <mailing@rotex1690.org>"
    @bcc          = people.collect{|person| "#{person.label} <#{person.email}>"} # .join (', ')
    @from         = "#{person.label} <#{person.email}>"
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


  def password(person,password)
    @subject      = '[ROTEX1690] '+person.first_name+", voici vos codes d'accès au site du Rotex 1690"
    @body[:person]   = person
    @body[:password] = password
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotex 1690 <no-reply@rotex1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end

  def test(person)
    @subject      = '[ROTEX1690] '+person.first_name+", ceci est un test"
    @body[:person]   = person
    @recipients   = "#{person.label} <#{person.email}>"
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

  def lost_login(person)
    @subject      = '[ROTEX1690] '+person.first_name+', voici votre nom d\'utilisateur'
    @body[:person] = person
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotex 1690 <no-reply@rotex1690.org>'
    @sent_on      = Time.now
    @headers      = {}
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
