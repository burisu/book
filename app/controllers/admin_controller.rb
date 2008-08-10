require 'scaffolding_extensions'

class AdminController < ApplicationController
  scaffold_all_models
  before_filter :authorize

  def authorize
    unless session[:current_person_id]
      redirect_to :controller=>:inter, :action=>:index
    else
      current_person=Person.find(session[:current_person_id])
      redirect_to(:controller=>:inter, :action=>:index) unless current_person.role.can_manage?(:all)
    end
  end
end
