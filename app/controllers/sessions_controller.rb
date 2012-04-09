# -*- coding: utf-8 -*-
class SessionsController < ApplicationController
  # ssl_only

  def new
    clean_people
    if session[:current_person_id]
      redirect_to myself_url
    end
  end


  def create
    person = Person.authenticate(params[:person][:user_name], params[:person][:password])
    if person        
      session[:last_request] = Time.now.to_i
      session[:current_person_id]=person.id
      session[:rights] = person.rights
      @@configuration.reload
      redirect_to(params[:redirect] ? params[:redirect] : myself_url)
      return
    else
      flash.now[:warning] = "Votre nom d'utilisateur ou votre mot de passe est incorrect ou vous n'êtes pas à jour de votre cotisation."
    end
    render :template=>"sessions/new"
  end

  def destroy
    session[:current_person_id] = nil
    reset_session
    redirect_to root_url
  end

  private

  def clean_people()
    begin
      ActiveRecord::SessionStore::Session.delete_all(["updated_at <= ?", Date.today-7.days])
      # Person.delete_all "NOT is_validated AND CURRENT_TIMESTAMP-created_at>'7 jours'::interval"
    rescue
      # Rien à faire de mieux
    end
  end
end
