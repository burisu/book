class AuthenticationController < ApplicationController
  ssl_only

  def index
    redirect_to :action=>:login
  end

  def login
    clean_people
    if request.post?
      person = Person.authenticate(params[:person][:user_name], params[:person][:password])
      if person        
        session[:current_person_id]=person.id
        session[:rights] = person.rights
        @@configuration.reload
        redirect_to :controller=>:suivi, :action=>:index
      else
        flash.now[:warning] = "Votre nom d'utilisateur ou votre mot de passe est incorrect ou vous n'êtes pas à jour de votre cotisation."
      end
    else
      if session[:current_person_id]
        redirect_to :controller=>:suivi
      end
    end
  end

  def logout
    session[:current_person_id] = nil
    reset_session
    redirect_to :controller=>:suivi, :action=>:index
  end


  def lost_password
    if request.post?
      @person = Person.find_by_user_name params[:person][:user_name]
      if @person
        Maily.deliver_lost_password(@person)
        flash.now[:notice] = 'Votre nouveau mot de passe vous a été envoyé à l\'adresse '+@person.email
      else
        flash.now[:notice] = 'Votre nom d\'utilisateur est inconnu'
      end
    end
  end
  
  def lost_login
    if request.post?
      @person = Person.find_by_email params[:person][:email]
      if @person
        Maily.deliver_lost_login @person
        flash.now[:notice] = 'Votre nom d\'utilisateur vous a été envoyé à l\'adresse '+@person.email
      else
        flash.now[:notice] = 'Votre e-mail est inconnu'
      end
    end
  end
    
  
  private
  def clean_people()
    begin
      PersonVersion.delete_all "NOT is_validated AND CURRENT_TIMESTAMP-created_at>'48 hours'::interval"
      Person.delete_all "NOT is_validated AND CURRENT_TIMESTAMP-created_at>'48 hours'::interval"
    rescue
      # Rien à faire de mieux
    end
  end
end
