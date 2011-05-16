# -*- coding: utf-8 -*-
class QuestionsController < ApplicationController

  after_filter :redirect_correctly, :except=>[:new, :create, :edit, :update]
  
  def new
    @question = Question.new(:name=>' ? ')
    render_form
  end
  
  def create
    questionnaire = Questionnaire.find(session[:current_questionnaire])
    @question = questionnaire.questions.new(params[:question])
    redirect_correctly if @question.save
    render_form
  end
  
  def edit
    @question = Question.find_by_id_and_questionnaire_id(params[:id], session[:current_questionnaire])
    render_form
  end
  
  def update
    @question = Question.find_by_id_and_questionnaire_id(params[:id], session[:current_questionnaire])
    redirect_correctly if @question.update_attributes(params[:question])
    render_form
  end
  
  def destroy
    @question = Question.find_by_id(params[:id])
    @question.destroy
    flash[:notice] = 'Suppression de '+@question.name+' effectuée'
  end

  def up
    @question = Question.find_by_id(params[:id])
    @question.move_higher if @question
  end
  
  def down
    @question = Question.find_by_id(params[:id])
    @question.move_lower if @question
  end
  
  protected
  
  def redirect_correctly()
    if request.xhr?
      render :inline=>"<%=dyta(:questionnaire_questions)-%>" 
    else
      redirect_to questionnaire_url(@question.questionnaire)    
    end    
  end

end
