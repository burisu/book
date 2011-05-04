# -*- coding: utf-8 -*-
class SuiviController < ApplicationController
  before_filter :authorize, :except=>[:access_denied, :logout]
  ssl_only

  def index
    # @questionnaires = Questionnaire.find(:all, :conditions=>["id IN (SELECT questionnaire_id FROM answers) OR CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE-'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE-'1 day'::INTERVAL)"])
    # @questionnaires = Questionnaire.find(:all, :conditions=>["id IN (SELECT questionnaire_id FROM answers) OR CURRENT_DATE BETWEEN COALESCE(started_on, CURRENT_DATE+'1 day'::INTERVAL) AND COALESCE(stopped_on, CURRENT_DATE+'1 day'::INTERVAL)"])
    @questionnaires = @current_person.questionnaires
  end


  def question
    return unless try_to_access :suivi
    @question = Question.find_by_id(params[:id])
    @question = Question.new(:name=>'') unless @question
    @questionnaire = Questionnaire.find(session[:current_questionnaire])
    if request.post?
      params[:question][:questionnaire_id] = @questionnaire.id
      if @question.update_attributes(params[:question]) and not request.xhr?
        redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id
      end
    elsif request.delete?
      if @question
        Question.destroy(@question)
        flash[:notice] = 'Suppression de '+@question.name+' effectuée'
      end
      redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id unless request.xhr?
    end
    render :inline=>"<%=dyta(:questionnaire_questions)-%>" if request.xhr?
  end

  def question_up
    return unless try_to_access :suivi
    @question = Question.find_by_id(params[:id])
    @question.move_higher if @question
    if request.xhr?
      render :inline=>"<%=dyta(:questionnaire_questions)-%>" 
    else
      redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id    
    end
  end
  
  def question_down
    return unless try_to_access :suivi
    @question = Question.find_by_id(params[:id])
    @question.move_lower if @question
    if request.xhr?
      render :inline=>"<%=dyta(:questionnaire_questions)-%>" 
    else
      redirect_to :action=>:questionnaire, :id=>@question.questionnaire_id    
    end
  end


  def access_denied
  end

end
