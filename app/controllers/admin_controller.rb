require 'scaffolding_extensions'

class AdminController < ApplicationController
  ssl_only
  scaffold_all_models
  before_filter :authorize

  def authorize
    unless session[:current_person_id]
      redirect_to :controller=>:home
    else
      current_person=Person.find(session[:current_person_id])
      redirect_to(:controller=>:home) unless access?
    end
  end
end
