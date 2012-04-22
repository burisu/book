# encoding: UTF-8
class GroupInterventionsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all group_interventions
  list :conditions => light_search_conditions(:group_interventions => [:nature_id, :group_id, :event_id, :started_at, :stopped_at, :description, :comment]) do |t|
    t.column :name, :through => :nature, :url => true
    t.column :name, :through => :group, :url => true
    t.column :name, :through => :event, :url => true
    t.column :started_at
    t.column :stopped_at
    t.column :description, :url => true
    t.column :comment
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @group_intervention = GroupIntervention.find(params[:id])
    session[:current_group_intervention_id] = @group_intervention.id
  end
  
  def new
    @group_intervention = GroupIntervention.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @group_intervention }
      format.xml  { render :xml => @group_intervention }
    end
  end
  
  def create
    @group_intervention = GroupIntervention.new(params[:group_intervention])
    respond_to do |format|
      if @group_intervention.save
        format.html { redirect_to @group_intervention }
        format.json { render json => @group_intervention, :status => :created, :location => @group_intervention }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @group_intervention.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @group_intervention = GroupIntervention.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @group_intervention = GroupIntervention.find(params[:id])
    respond_to do |format|
      if @group_intervention.update_attributes(params[:group_intervention])
        format.html { redirect_to @group_intervention }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @group_intervention.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @group_intervention = GroupIntervention.find(params[:id])
    @group_intervention.destroy
    respond_to do |format|
      format.html { redirect_to group_interventions_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
