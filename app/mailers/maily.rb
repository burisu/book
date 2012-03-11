# -*- coding: utf-8 -*-
# encoding: utf-8
class Maily < ActionMailer::Base


  def confirmation(person)
    @subject      = '[ROTARY1690] '+person.first_name+', il est temps de confirmer de votre inscription'
    @body[:person] = person
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end
  
  def has_subscribed(person, subscription)
    @subject      = '[ROTEX1690] '+person.first_name+', votre cotisation a été enregistrée'
    @body[:person] = person
    @body[:subscription] = subscription
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotex 1690 <no-reply@rotex1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end
  
  def approval(person)
    @subject      = '[ROTARY1690] '+person.first_name+', votre accès a été autorisé'
    @body[:person] = person
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end

  def chase(subscription, message)
    person = subscription.person
    @subject      = '[ROTEX1690] '+person.first_name+', pensez à renouveler votre cotisation'
    @body[:subscription] = subscription
    @body[:message] = message
    people = Person.mandated_for(['tresor', 'admin'])
    @bcc          = people.collect{|p| "#{p.label} <#{p.email}>"}
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotex 1690 <no-reply@rotex1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end
  

  def notification(nature, person, resp=nil)
    @subject      = '[ROTARY1690] Notification : '+
      if nature==:subscription
        "Enregistrement d'un nouveau membre (#{person.label})"
      elsif nature==:activation
        "Activation de compte (#{person.label})"
      elsif nature==:has_subscribed
        "Enregistrement de cotisation effectué pour #{person.label}"
      elsif nature==:waiting_payment
        "Commande effectuée par #{person.is_a?(Sale) ? person.client_email : person.label}"
      elsif nature==:approval
        "Demande d'acceptation pour #{person.label}"
      else
        "Inconnue"
      end
    @body[:nature] = nature
    @body[:person] = person
    @body[:responsible] = resp
    people = Person.mandated_for(['tresor', 'admin'])
    @recipients   = people.collect{|p| "#{p.label} <#{p.email}>"}
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end
  
  def message(person, options={})
    @subject      = '[ROTEX1690] '+options[:subject].to_s
    @body[:body] = options[:body].to_s
    conditions = {}
    conditions[:arrival_country_id] = Country.find(options[:arrival_id]).id unless options[:arrival_id].blank?
    unless options[:promotion_id].blank?
      conditions[:promotion_id] = Promotion.find(options[:promotion_id]).id
    end
    people = Person.find(:all, :conditions=>conditions)
    @recipients   = "#{country.name.to_s+' '+promotion.name.to_s} <mailing@rotex1690.org>"
    @bcc          = people.collect{|person| "#{person.label} <#{person.email}>"} # .join (', ')
    @from         = "#{person.label} <#{person.email}>"
    @sent_on      = Time.now
    @headers      = {}
  end



  def answer(ans)
    @subject      = "[ROTARY1690] Notification : Réponse à un questionnaire de "+ans.person.label
    @body[:person] = ans.person
    @body[:answer] = ans
    people = Person.mandated_for(['yeoout', 'yeo'])
    @recipients   = people.collect{|p| "#{p.label} <#{p.email}>"}
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end

  def lost_login(person)
    @subject      = '[ROTARY1690] '+person.first_name+', voici votre nom d\'utilisateur'
    @body[:person] = person
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end

  def lost_password(person)
    @subject      = '[ROTARY1690] '+person.first_name+', voici votre nouveau mot de passe'
    @body[:person]   = person
    @body[:password] = person.change_password
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end

  def new_mail(person)
    @subject      = '[ROTARY1690] '+person.first_name+', vous pouvez activer votre nouvel adresse e-mail'
    @body[:person]   = person
    @recipients   = "#{person.label} <#{person.replacement_email}>"
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end


  def unvalidation(answer, message)
    @subject      = "[ROTARY1690] Invalidation de votre questionnaire #{answer.questionnaire.name}"
    @body[:message]   = message
    @recipients   = "#{answer.person.label} <#{answer.person.email}>"
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end
  

  def awakenings(sleepers, questionnaire, expedier)
    ["bricetexier@yahoo.fr", "michel@gilantoli.com"]
    mails = sleepers.collect{|x| "#{x.label} <#{x.email}>"}
    @subject      = "[ROTARY1690] Urgent! Le Rotary 1690 attend votre réponse au questionnaire obligatoire"
    @body[:questionnaire] = questionnaire
    @body[:sleepers] = mails
    @recipients   = mails
    @bcc          = expedier.email
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end
  


  def password(person,password)
    @subject      = '[ROTARY1690] '+person.first_name+", voici vos codes d'accès aux sites Jeunesse du District 1690"
    @body[:person]   = person
    @body[:password] = password
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
    @sent_on      = Time.now
    @headers      = {}
  end

  def test(person)
    @subject      = '[ROTARY1690] '+person.first_name+", ceci est un test"
    @body[:person]   = person
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
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
    @subject      = '[ROTARY1690] '+person.first_name+', voici votre nom d\'utilisateur'
    @body[:person] = person
    @recipients   = "#{person.label} <#{person.email}>"
    @from         = 'Rotary 1690 <no-reply@rotary1690.org>'
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
