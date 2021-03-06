# encoding: UTF-8
class GroupsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all groups
  list(:conditions => light_search_conditions(:groups => [:name, :number, :zone_nature_id, :parent_id, :country])) do |t|
    t.column :name, :url => true
    t.column :number
    t.column :name, :through => :zone_nature, :url => true
    t.column :name, :through => :parent, :url => true
    t.column :country
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all interventions of one group
  list(:interventions, :model => 'GroupIntervention', :conditions => ['group_id = ?', ['session[:current_group_id]']]) do |t|
    t.column :name, :through => :nature, :url => true
    t.column :name, :through => :event, :url => true
    t.column :started_at
    t.column :stopped_at
    t.column :description, :url => true
    t.column :comment
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @group = Group.find(params[:id])
    session[:current_group_id] = @group.id
  end
  
  def new
    @group = Group.new(:nature_id => params[:nature_id].to_i, :parent_id => params[:parent_id].to_i, :zone_nature_id => params[:zone_nature_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @group }
      format.xml  { render :xml => @group }
    end
  end
  
  def create
    @group = Group.new(params[:group])
    respond_to do |format|
      if @group.save
        format.html { redirect_to (params[:redirect] || @group) }
        format.json { render json => @group, :status => :created, :location => @group }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @group = Group.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @group = Group.find(params[:id])
    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to (params[:redirect] || @group) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || groups_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
