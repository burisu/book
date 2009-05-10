# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_rotex_session_id'
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
  end  
  
  private
  
  def authorize
    unless session[:current_person_id]
      session[:original_uri] = request.request_uri
      session[:last_url]= request.url
      redirect_to :controller=>"/auth", :action=>"login"
    end
    session[:last_request] ||= Time.now.to_i
    if Time.now.to_i-session[:last_request]>3600
      reset_session
      flash[:warning] = 'La session est expirée. Veuillez vous reconnecter.'
      redirect_to :controller=>:auth, :action=>:login
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
