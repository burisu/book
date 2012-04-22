# encoding: UTF-8
class QuestionItemsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all question_items
  list :conditions => light_search_conditions(:question_items => [:name, :explanation, :position, :question_id, :theme_id]) do |t|
    t.column :name, :url => true
    t.column :explanation
    t.column :position
    t.column :name, :through => :question, :url => true
    t.column :name, :through => :theme, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all answer_items of one question_item
  list(:answer_items, :conditions => ['question_item_id = ?', ['session[:current_question_item_id]']]) do |t|
    t.column :content
    t.column :id, :through => :answer, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def show
    @question_item = QuestionItem.find(params[:id])
    session[:current_question_item_id] = @question_item.id
  end
  
  def new
    @question_item = QuestionItem.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @question_item }
      format.xml  { render :xml => @question_item }
    end
  end
  
  def create
    @question_item = QuestionItem.new(params[:question_item])
    respond_to do |format|
      if @question_item.save
        format.html { redirect_to @question_item }
        format.json { render json => @question_item, :status => :created, :location => @question_item }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @question_item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @question_item = QuestionItem.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @question_item = QuestionItem.find(params[:id])
    respond_to do |format|
      if @question_item.update_attributes(params[:question_item])
        format.html { redirect_to @question_item }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @question_item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @question_item = QuestionItem.find(params[:id])
    @question_item.destroy
    respond_to do |format|
      format.html { redirect_to question_items_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
