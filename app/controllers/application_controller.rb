# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers  
  # Pick a unique cookie name to distinguish our session data from others'
  # session :session_key => '_rotex_session_id'
  before_filter :init

  @@configuration = Configuration.the_one

  hide_action :conf
  def conf
    @@configuration
  end

  def init
    if session[:current_person_id]
      @current_person=Person.find(session[:current_person_id])
      @current_person_id = @current_person.id
    end
    @controller_name  = self.controller_name
    @action_name = action_name
    @action = @controller_name+':'+@action_name
    @title = 'Bienvenue'
    domain = request.domain
    @vision = if ['student-exchange-rotary.org', 'rotary1690.org', 'localhost'].include? request.domain
                :rotary
              else
                :rotex
              end
    session[:last_request] = Time.now.to_i
    session[:history] ||= []
    session[:history].delete_at(0) if session[:no_history]
    if request.get? and not request.xhr?
      if session[:history][1]==request.url
        session[:history].delete_at(0)
      elsif session[:history][0]!=request.url
        session[:history].insert(0, request.url)
      end
      session[:no_history] = false
    end

  end  
  

  hide_action :access
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
 
  private

  protected
  
  def try_to_access(right=:all)
    unless access? right
      redirect_to :action=>:access_denied 
      return false
    end
    return true
  end

  def authorize
    if @vision!=:rotex and self.controller_name=='intra'
      redirect_to :controller=>:suivi 
      return
    end
    if @vision==:rotex and self.controller_name=='suivi'
      redirect_to :controller=>:intra 
      return
    end


    unless session[:current_person_id]
      session[:last_url] = request.url
      session[:original_uri] = request.request_uri
      redirect_to :controller=>:authentication, :action=>:login
      return
    end
    session[:last_request] ||= Time.now.to_i
    if Time.now.to_i-session[:last_request]>3600
      reset_session
      flash[:warning] = 'La session est expirée. Veuillez vous reconnecter.'
      redirect_to :controller=>:authentication, :action=>:login
      return
    end

    if @vision==:rotary and not access?(:suivi) and not (@current_person and @current_person.student?)
      redirect_to :controller=>:suivi, :action=>:access_denied
      return
    end

  end




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
    @operation    = a[-1].to_sym
    @partial = options[:partial]||a[0..-2].join('_')+'_form'
    @options = options
    begin
      render :template=>options[:template]||'shared/form_'+@operation.to_s
    rescue ActionController::DoubleRenderError
    end
  end




  # Build standard actions to manage records of a model
  def self.manage(name, defaults={})
    operations = [:create, :update, :delete]

    record_name = name.to_s.singularize
    model = name.to_s.singularize.classify.constantize
    code = ''
    methods_prefix = record_name
    
    if operations.include? :create
      code += "def #{methods_prefix}_create\n"
      code += "  if request.post?\n"
      code += "    @#{record_name} = #{model.name}.new(params[:#{record_name}])\n"
      # code += "    @#{record_name}.company_id = @current_company.id\n"
      code += "    redirect_to_back if @#{record_name}.save\n"
      code += "  else\n"
      values = defaults.collect{|k,v| ":#{k}=>(#{v})"}.join(", ")
      code += "    @#{record_name} = #{model.name}.new(#{values})\n"
      code += "  end\n"
      code += "  render_form\n"
      code += "end\n"
    end
    
    if operations.include? :update
      # this action updates an existing employee with a form.
      code += "def #{methods_prefix}_update\n"
      code += "  return unless @#{record_name} = find_and_check(:#{record_name}, params[:id])\n"
      code += "  if request.post? or request.put?\n"
      code += "    redirect_to_back if @#{record_name}.update_attributes(params[:#{record_name}])\n"
      code += "  end\n"
      values = model.content_columns.collect do |c|
        value = "@#{record_name}.#{c.name}"
        value = "(#{value}.nil? ? nil : ::I18n.localize(#{value}))" if [:date, :datetime].include? c.type
        ":#{c.name}=>#{value}"
      end.join(", ")
      code += "  @title = {#{values}}\n"
      code += "  render_form\n"
      code += "end\n"
    end

    if operations.include? :delete
      # this action deletes or hides an existing employee.
      code += "def #{methods_prefix}_delete\n"
      code += "  return unless @#{record_name} = find_and_check(:#{record_name}, params[:id])\n"
      code += "  if request.delete?\n"
      code += "    #{model.name}.destroy(@#{record_name}.id)\n"
      code += "    flash[:notice]=::I18n.t('general.record_has_been_correctly_removed')\n"
      code += "  else\n"
      code += "    flash[:error]=::I18n.t('general.record_has_not_been_removed')\n"
      code += "  end\n"
      code += "  redirect_to :action=>:#{name}\n"
      code += "end\n"
    end

    # list = code.split("\n"); list.each_index{|x| puts((x+1).to_s.rjust(4)+": "+list[x])}
    
    class_eval(code)
    
  end




end
