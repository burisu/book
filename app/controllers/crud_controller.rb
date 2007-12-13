class CrudController < ApplicationController
  scaffold_all_models
  before_filter :authorize

  def authorize
    unless session[:current_person_id]
      redirect_to :controller=>:multy, :action=>:index
    else
      current_person=Person.find(session[:current_person_id])
      if current_person.role.restriction_level !=0
        redirect_to :controller=>:multy, :action=>:index
      end
    end
  end
end
