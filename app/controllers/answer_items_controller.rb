# encoding: UTF-8
class AnswerItemsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all answer_items
  list(:conditions => light_search_conditions(:answer_items => [:content, :answer_id, :question_item_id])) do |t|
    t.column :content
    t.column :id, :through => :answer, :url => true
    t.column :name, :through => :question_item, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @answer_item = AnswerItem.find(params[:id])
    session[:current_answer_item_id] = @answer_item.id
  end
  
  def new
    @answer_item = AnswerItem.new(:answer_id => params[:answer_id].to_i, :question_item_id => params[:question_item_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @answer_item }
      format.xml  { render :xml => @answer_item }
    end
  end
  
  def create
    @answer_item = AnswerItem.new(params[:answer_item])
    respond_to do |format|
      if @answer_item.save
        format.html { redirect_to (params[:redirect] || @answer_item) }
        format.json { render json => @answer_item, :status => :created, :location => @answer_item }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @answer_item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @answer_item = AnswerItem.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @answer_item = AnswerItem.find(params[:id])
    respond_to do |format|
      if @answer_item.update_attributes(params[:answer_item])
        format.html { redirect_to (params[:redirect] || @answer_item) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @answer_item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @answer_item = AnswerItem.find(params[:id])
    @answer_item.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || answer_items_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
