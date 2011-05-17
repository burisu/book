# -*- coding: undecided -*-
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers  
  include ExceptionNotifiable
  include SslRequirement

  ssl_only

  before_filter :authorize


  protected

  def authorize()
    @title = 'Bienvenue'

    # Chargement de la personne connectée
    @current_person = Person.find(session[:current_person_id]) if session[:current_person_id]

    # Verification public
    current_rights = MandateNature.rights_for(self.controller_name, action_name)
    return if current_rights.include? :__public__

    # Verification utilisateur
    unless @current_person
      flash[:warning] = 'Veuillez vous connecter.'
      redirect_to new_session_url(:redirect=>request.url)
      return
    end

    # Verification expiration
    session[:last_request] ||= 0
    if Time.now.to_i-session[:last_request]>3600
      reset_session
      flash[:warning] = 'La session est expirée. Veuillez vous reconnecter.'
      redirect_to new_session_url(:redirect=>request.url)
      return
    end
    session[:last_request] = Time.now.to_i

    # Autorisation immédiate pour un administrateur
    return if session[:rights].include?(:all) or current_rights.include? :__protected__

    # Verification des cotisations
    unless @current_person.has_subscribed_on?
      flash[:warning] = "Vous n'êtes pas à jour de votre cotisation pour pouvoir utiliser cette partie du site"
      redirect_to new_sale_url
      return
    end

    # Réservé au membres seulement
    return if current_rights.include? :__private__

    # Verification droits
    unless (session[:rights] & current_rights).size > 0
      flash[:warning] = "Accès réservé"
      redirect_to root_url
      return      
    end    
  end

end
