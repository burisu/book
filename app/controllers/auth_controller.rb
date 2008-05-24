class AuthController < ApplicationController

  def index
    redirect_to :action=>:login
  end

  def login
    if request.post?
      person=Person.authenticate(params[:person][:user_name],params[:person][:password])
      if person
        session[:current_person_id]=person.id
        redirect_to :controller=>:me, :action=>:messenger
      else
        flash[:warning]='Votre nom d''utilisateur ou votre mot de passe est incorrect, veuillez recommencer !'
      end
    end
    
  end

  def logout
    session[:current_person_id]=nil
    redirect_to :controller=>:auth, :action=>:login
  end

  def subscribe
    if request.post?
      role = Role.find_or_create('role')
      params[:person][:role_id] = role.id
      @person = Person.new params[:person]
      if @person.save
        redirect_to :controller=>:multy, :action=>:index
      end
    else
      @person = Person.new
    end
  end

  def lost_password
  end
end
