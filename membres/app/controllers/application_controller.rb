# -*- coding: utf-8 -*-
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers  
  include ExceptionNotifiable
  include SslRequirement

  ssl_only

  before_filter :authorize

  @@configuration = Configuration.the_one

  hide_action :conf
  def conf()
    @@configuration
  end
  

  hide_action :access?
  def access?(right=:all)
    session[:rights] ||= []
    if session[:rights].include? :all
      return true
    elsif right.is_a? Array
      for r in right
        return true if session[:rights].include?(r)
      end
    else
      return session[:rights].include?(right)
    end
    return false
  end
 


  protected


  def self.search_conditions(model_name, columns)
    model = model_name.to_s.classify.constantize
    columns = [columns] if [String, Symbol].include? columns.class 
    columns = columns.collect{|k,v| v.collect{|x| "#{k}.#{x}"}} if columns.is_a? Hash
    columns.flatten!
    raise Exception.new("Bad columns: "+columns.inspect) unless columns.is_a? Array
    code = ""
    code+="c=['true']\n"
    code+="session[:#{model.name.underscore}_key].to_s.lower.split(/\\s+/).each{|kw| kw='%'+kw+'%';"
    # This line is incompatible with MySQL...
    # code+="c[0]+=' AND (#{columns.collect{|x| 'LOWER(CAST('+x.to_s+' AS TEXT)) LIKE ?'}.join(' OR ')})';c+=[#{(['kw']*columns.size).join(',')}]}\n"
    if ActiveRecord::Base.connection.adapter_name == "MySQL"
      code+="c[0]+=' AND ("+columns.collect{|x| 'LOWER(CAST('+x.to_s+' AS CHAR)) LIKE ?'}.join(' OR ')+")';\n"
    else
      code+="c[0]+=' AND ("+columns.collect{|x| 'LOWER(CAST('+x.to_s+' AS VARCHAR)) LIKE ?'}.join(' OR ')+")';\n"
    end
    code+="c+=[#{(['kw']*columns.size).join(',')}]"
    code+="}\n"
    code+="c"
    code
  end




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
    # unless @current_person.has_subscribed_on?
    #   flash[:warning] = "Vous n'êtes pas à jour de votre cotisation pour pouvoir utiliser cette partie du site"
    #   redirect_to new_sale_url
    #   return
    # end

    # Réservé au membres seulement
    return if current_rights.include? :__private__

    # Verification droits
    unless (session[:rights] & current_rights).size > 0
      flash[:warning] = "Accès réservé"
      redirect_to root_url
      return      
    end    
  end



  # Check record existence
  def find_and_check(model, id, options={})
    model = model.to_s
    record = model.classify.constantize.find_by_id(id)
    if record.nil?
      flash[:error] = ::I18n.t("general.unavailable.#{model.to_s}", :value=>id)
      redirect_to_back # :action=>options[:url]||model.pluralize
    end
    record
  end

  def render_form(options={})
    a = action_name.split '_'
    @_operation    = options[:operation]||a[-1].to_sym
    @_operation = :edit if @_operation == :update
    @_operation = :new if @_operation == :create
    @_partial = (options[:partial]||a[0..-2].join('_')).to_s
    @_partial += "_" unless @_partial.blank?
    @_partial += "form"
    @_options = options
    begin
      render :template=>options[:template]||'shared/form_'+@_operation.to_s
    rescue ActionController::DoubleRenderError
    end
  end

end
