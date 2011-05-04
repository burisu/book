# -*- coding: utf-8 -*-
class SuiviController < ApplicationController
  before_filter :authorize, :except=>[:access_denied, :logout]
  ssl_only

  def index
    # @questionnaires = Questionnaire.find(:all, :conditions=>["id IN (SELECT questionnaire_id FROM answers) OR CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE-'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE-'1 day'::INTERVAL)"])
    # @questionnaires = Questionnaire.find(:all, :conditions=>["id IN (SELECT questionnaire_id FROM answers) OR CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE+'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE+'1 day'::INTERVAL)"])
    @questionnaires = @current_person.questionnaires
  end


  def access_denied
  end

end
