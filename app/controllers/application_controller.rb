# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :localize
  # before_filter :authorize

  # @@configuration = Configuration.the_one

  # hide_action :conf
  # def conf()
  #   @@configuration
  # end
  

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

  def self.light_search_conditions(search={}, options={})
    conditions = options[:conditions] || 'c'
    options[:except] ||= []
    options[:filters] ||= {}
    variable ||= options[:variable] || "params[:q]"
    tables = search.keys.select{|t| !options[:except].include? t}
    # code = "\n#{conditions} = ['"+tables.collect{|t| "#{ActiveRecord::Base.connection.quote_table_name(t.is_a?(Symbol) ? t.to_s.classify.constantize.table_name : t)}.company_id=?"}.join(' AND ')+"'"+", @current_company.id"*tables.size+"]\n"
    code = "\n#{conditions} = ['']\n"
    columns = search.collect{|t, cs| cs.collect{|c| "#{ActiveRecord::Base.connection.quote_table_name(t.is_a?(Symbol) ? t.to_s.classify.constantize.table_name : t)}.#{ActiveRecord::Base.connection.quote_column_name(c)}"}}.flatten
    code += "for kw in #{variable}.to_s.lower.split(/\\s+/)\n"
    code += "  kw = '%'+kw+'%'\n"
    filters = columns.collect do |x| 
      # This line is incompatible with MySQL...
      if ActiveRecord::Base.connection.adapter_name.match(/^mysql/i)
        'LOWER(CAST('+x.to_s+' AS CHAR)) LIKE ?'
      else
        'LOWER(CAST('+x.to_s+' AS VARCHAR)) LIKE ?'
      end
    end
    values = '['+(['kw']*columns.size).join(', ')+']'
    for k, v in options[:filters]
      filters << k
      v = '['+v.join(', ')+']' if v.is_a? Array
      values += "+"+v
    end
    code += "  #{conditions}[0] += ' AND (#{filters.join(' OR ')})'\n"
    code += "  #{conditions} += #{values}\n"
    code += "end\n"
    code += "#{conditions}"
    return code
  end


  def localize()
    I18n.default_locale = I18n.locale = :fra
  end


  def authorize()
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


  def render_restfully_form(options={})
    operation = action_name.to_sym
    operation = (operation==:create ? :new : operation==:update ? :edit : operation)
    partial   = options[:partial]||'form'
    render(:template=>options[:template]||"forms/#{operation}", :locals=>{:operation=>operation, :partial=>partial, :options=>options})
  end


  # Build standard RESTful actions to manage records of a model
  def self.manage_restfully(defaults={})
    name = controller_name
    t3e = defaults.delete(:t3e)
    url = defaults.delete(:redirect_to)
    xhr = defaults.delete(:xhr)
    durl = defaults.delete(:destroy_to)
    partial = defaults.delete(:partial)
    partial = " :partial=>'#{partial}'" if partial
    record_name = name.to_s.singularize
    model = name.to_s.singularize.classify.constantize
    code = ''
    
    code += "def new\n"
    values = defaults.collect{|k,v| ":#{k}=>(#{v})"}.join(", ")
    code += "  @#{record_name} = #{model.name}.new(#{values})\n"
    if xhr
      code += "  if request.xhr?\n"
      code += "    render :partial=>#{xhr.is_a?(String) ? xhr.inspect : 'detail_form'.inspect}\n"
      code += "  else\n"
      code += "    render_restfully_form#{partial}\n"
      code += "  end\n"
    else
      code += "  render_restfully_form#{partial}\n"
    end
    code += "end\n"

    code += "def create\n"
    code += "  @#{record_name} = #{model.name}.new(params[:#{record_name}])\n"
    # code += "  @#{record_name}.company_id = @current_company.id\n"
    code += "  return if save_and_redirect(@#{record_name}#{',  :url=>'+url if url})\n"
    code += "  render_restfully_form#{partial}\n"
    code += "end\n"

    # this action updates an existing record with a form.
    code += "def edit\n"
    code += "  return unless @#{record_name} = find_and_check(:#{record_name})\n"
    code += "  t3e(@#{record_name}.attributes"+(t3e ? ".merge("+t3e.collect{|k,v| ":#{k}=>(#{v})"}.join(", ")+")" : "")+")\n"
    code += "  render_restfully_form#{partial}\n"
    code += "end\n"

    code += "def update\n"
    code += "  return unless @#{record_name} = find_and_check(:#{record_name})\n"
    code += "  t3e(@#{record_name}.attributes"+(t3e ? ".merge("+t3e.collect{|k,v| ":#{k}=>(#{v})"}.join(", ")+")" : "")+")\n"
    # raise Exception.new("You must put :company_id in attr_readonly of #{model.name} (#{model.readonly_attributes.inspect})") if model.readonly_attributes.nil? or not model.readonly_attributes.to_a.join.match(/company_id/)
    code += "  @#{record_name}.attributes = params[:#{record_name}]\n"
    code += "  return if save_and_redirect(@#{record_name}#{', :url=>('+url+')' if url})\n"
    code += "  render_restfully_form#{partial}\n"
    code += "end\n"

    # this action deletes or hides an existing record.
    code += "def destroy\n"
    code += "  return unless @#{record_name} = find_and_check(:#{record_name})\n"
    if model.instance_methods.include?("destroyable?")
      code += "  if @#{record_name}.destroyable?\n"
      code += "    #{model.name}.destroy(@#{record_name}.id)\n"
      code += "    notify_success(:record_has_been_correctly_removed)\n"
      code += "  else\n"
      code += "    notify_error(:record_cannot_be_removed)\n"
      code += "  end\n"
    else
      code += "  #{model.name}.destroy(@#{record_name}.id)\n"
      code += "  notify_success(:record_has_been_correctly_removed)\n"
    end
    # code += "  redirect_to #{durl ? durl : model.name.underscore.pluralize+'_url'}\n"
    code += "  #{durl ? 'redirect_to '+durl : 'redirect_to_current'}\n"
    code += "end\n"

    # list = code.split("\n"); list.each_index{|x| puts((x+1).to_s.rjust(4)+": "+list[x])}    
    class_eval(code)
  end



end
