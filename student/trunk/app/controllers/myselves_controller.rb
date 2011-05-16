# -*- coding: utf-8 -*-
class MyselvesController < ApplicationController

  def show
    @questionnaires = @current_person.questionnaires
  end

  def access_denied
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
    
end
