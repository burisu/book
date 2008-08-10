class AuthController < ApplicationController

  def index
    redirect_to :action=>:login
  end

  def login
    clean_people
    if request.post?
      person=Person.authenticate(params[:person][:user_name],params[:person][:password])
      if person
        session[:current_person_id]=person.id
        redirect_to :controller=>:intra, :action=>:profile
      else
        flash.now[:warning]='Votre nom d\'utilisateur ou votre mot de passe est incorrect, veuillez recommencer !'
      end
    end
  end

  def logout
    session[:current_person_id]=nil
    redirect_to :controller=>:inter, :action=>:index
  end

  def subscribe
    @register = true
    if request.post?
      role = Role.none
      params[:person][:role_id] = role.id
      @person = Person.new params[:person]
      @person.email = params[:person][:email]
      @person.is_validated = false
      @person.is_locked = true
      @person.is_user   = true
      if @person.save_with_captcha
        @register = false
        Maily.deliver_confirmation @person
      end
    else
      @person = Person.new
    end
  end
  
  def activate
    clean_people
    @person = Person.find_by_validation params[:id]
    @person.forced = true
    @activation = 0
    unless @person.nil?
      unless @person.is_validated
        @person.is_validated = true
        @person.is_locked = true
        @person.save!
        @activation += 1
      end
      unless @person.replacement_email.blank?
        @person.email = @person.replacement_email
        @person.replacement_email = nil
        @person.save!
        @activation += 2
      end
    end
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
  
  def change_password
    if request.post?
      @person = @current_person
      @person.test_password = params[:person][:test_password]
      @person.password = params[:person][:password]
      @person.password_confirmation = params[:person][:password_confirmation]
      if @person.save
        flash[:notice] = 'Votre mot de passe a été mis à jour avec succès !'
        redirect_to :controller=>:me, :action=>:profile
      end
    end
  end

  def change_email
    if request.post?
      @person = @current_person
      @person.test_password = params[:person][:test_password]
      @person.replacement_email = params[:person][:replacement_email]
#      @person.errors.add(:test_password, "est incorrect") unless @person.confirm(params[:person][:test_password])
      if @person.save
        Maily.deliver_new_mail(@person)
        flash[:notice] = 'L\'e-mail à valider a été envoyé à l\'adresse '+@person.replacement_email
        redirect_to :controller=>:me, :action=>:profile
      end
    end
  end
  
  private
  def clean_people
    Person.delete_all "NOT is_validated AND CURRENT_TIMESTAMP-created_at>'24 hours'::interval"
  end
end
