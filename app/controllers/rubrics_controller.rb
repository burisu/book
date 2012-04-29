# encoding: UTF-8
class RubricsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all rubrics
  list(:conditions => light_search_conditions(:rubrics => [:name, :code, :logo, :description, :parent_id, :rubrics_count])) do |t|
    t.column :name, :url => true
    t.column :code
    t.column :logo
    t.column :description
    t.column :name, :through => :parent, :url => true
    t.column :rubrics_count
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all articles of one rubric
  list(:articles, :conditions => ['rubric_id = ?', ['session[:current_rubric_id]']]) do |t|
    t.column :title
    t.column :intro
    t.column :body
    t.column :done_on
    t.column :bad_natures
    t.column :status
    t.column :document
    t.column :label, :through => :author, :url => true
    t.column :language
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @rubric = Rubric.find(params[:id])
    session[:current_rubric_id] = @rubric.id
  end
  
  def new
    @rubric = Rubric.new(:parent_id => params[:parent_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @rubric }
      format.xml  { render :xml => @rubric }
    end
  end
  
  def create
    @rubric = Rubric.new(params[:rubric])
    respond_to do |format|
      if @rubric.save
        format.html { redirect_to (params[:redirect] || @rubric) }
        format.json { render json => @rubric, :status => :created, :location => @rubric }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @rubric.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @rubric = Rubric.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @rubric = Rubric.find(params[:id])
    respond_to do |format|
      if @rubric.update_attributes(params[:rubric])
        format.html { redirect_to (params[:redirect] || @rubric) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @rubric.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @rubric = Rubric.find(params[:id])
    @rubric.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || rubrics_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
