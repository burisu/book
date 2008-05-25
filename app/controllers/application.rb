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
  end
  
  
  private
  
  def authorize
		unless session[:current_person_id]
			session[:original_uri] = request.request_uri
			redirect_to :controller=>"/auth", :action=>"login"
		end
  end

end
