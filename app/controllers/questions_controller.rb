# encoding: UTF-8
class QuestionsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all questions
  list(:conditions => light_search_conditions(:questions => [:name, :intro, :comment, :started_on, :stopped_on, :promotion_id])) do |t|
    t.column :name, :url => true
    t.column :intro
    t.column :comment
    t.column :started_on
    t.column :stopped_on
    t.column :name, :through => :promotion, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all answers of one question
  list(:answers, :conditions => ['question_id = ?', ['session[:current_question_id]']]) do |t|
    t.column :created_on
    t.column :ready
    t.column :locked
    t.column :label, :through => :person, :url => true
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  # List all items of one question
  list(:items, :model => 'QuestionItem', :conditions => ['question_id = ?', ['session[:current_question_id]']]) do |t|
    t.column :name, :url => true
    t.column :explanation
    t.column :position
    t.column :name, :through => :theme, :url => true
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @question = Question.find(params[:id])
    session[:current_question_id] = @question.id
  end
  
  def new
    @question = Question.new(:promotion_id => params[:promotion_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @question }
      format.xml  { render :xml => @question }
    end
  end
  
  def create
    @question = Question.new(params[:question])
    respond_to do |format|
      if @question.save
        format.html { redirect_to (params[:redirect] || @question) }
        format.json { render json => @question, :status => :created, :location => @question }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @question.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @question = Question.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @question = Question.find(params[:id])
    respond_to do |format|
      if @question.update_attributes(params[:question])
        format.html { redirect_to (params[:redirect] || @question) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @question.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || questions_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
