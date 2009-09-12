# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers  
  # Pick a unique cookie name to distinguish our session data from others'
  # session :session_key => '_rotex_session_id'
  before_filter :init
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
      session[:original_uri] = request.request_uri
      session[:last_url]= request.url
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

end
