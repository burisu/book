# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_rotex_session_id'
  before_filter :init
  
  def init
    if session[:current_person_id]
      @current_person=Person.find(session[:current_person_id])
      @current_person_id = @current_person.id
    end
    @action_name=action_name
  end
end
