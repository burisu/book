# encoding: UTF-8
class ActivitiesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all activities
  list :conditions => light_search_conditions(:activities => [:sector_id, :label, :name, :code]) do |t|
    t.column :name, :through => :sector, :url => true
    t.column :label, :url => true
    t.column :name
    t.column :code
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @activity = Activity.find(params[:id])
    session[:current_activity_id] = @activity.id
  end
  
  def new
    @activity = Activity.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @activity }
      format.xml  { render :xml => @activity }
    end
  end
  
  def create
    @activity = Activity.new(params[:activity])
    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity }
        format.json { render json => @activity, :status => :created, :location => @activity }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @activity = Activity.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @activity = Activity.find(params[:id])
    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        format.html { redirect_to @activity }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to activities_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
