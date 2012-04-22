# encoding: UTF-8
class AnswersController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all answers
  list :conditions => light_search_conditions(:answers => [:created_on, :ready, :locked, :person_id, :question_id]) do |t|
    t.column :created_on
    t.column :ready
    t.column :locked
    t.column :label, :through => :person, :url => true
    t.column :name, :through => :question, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all items of one answer
  list(:items, :model => 'AnswerItem', :conditions => ['answer_id = ?', ['session[:current_answer_id]']]) do |t|
    t.column :content
    t.column :name, :through => :question_item, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def show
    @answer = Answer.find(params[:id])
    session[:current_answer_id] = @answer.id
  end
  
  def new
    @answer = Answer.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @answer }
      format.xml  { render :xml => @answer }
    end
  end
  
  def create
    @answer = Answer.new(params[:answer])
    respond_to do |format|
      if @answer.save
        format.html { redirect_to @answer }
        format.json { render json => @answer, :status => :created, :location => @answer }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @answer.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @answer = Answer.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @answer = Answer.find(params[:id])
    respond_to do |format|
      if @answer.update_attributes(params[:answer])
        format.html { redirect_to @answer }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @answer.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @answer = Answer.find(params[:id])
    @answer.destroy
    respond_to do |format|
      format.html { redirect_to answers_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
