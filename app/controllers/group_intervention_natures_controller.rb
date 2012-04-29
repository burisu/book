# encoding: UTF-8
class GroupInterventionNaturesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all group_intervention_natures
  list(:conditions => light_search_conditions(:group_intervention_natures => [:name, :description, :comment])) do |t|
    t.column :name, :url => true
    t.column :description
    t.column :comment
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all group_interventions of one group_intervention_nature
  list(:group_interventions, :conditions => ['nature_id = ?', ['session[:current_group_intervention_nature_id]']]) do |t|
    t.column :name, :through => :group, :url => true
    t.column :name, :through => :event, :url => true
    t.column :started_at
    t.column :stopped_at
    t.column :description, :url => true
    t.column :comment
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @group_intervention_nature = GroupInterventionNature.find(params[:id])
    session[:current_group_intervention_nature_id] = @group_intervention_nature.id
  end
  
  def new
    @group_intervention_nature = GroupInterventionNature.new()
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @group_intervention_nature }
      format.xml  { render :xml => @group_intervention_nature }
    end
  end
  
  def create
    @group_intervention_nature = GroupInterventionNature.new(params[:group_intervention_nature])
    respond_to do |format|
      if @group_intervention_nature.save
        format.html { redirect_to (params[:redirect] || @group_intervention_nature) }
        format.json { render json => @group_intervention_nature, :status => :created, :location => @group_intervention_nature }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @group_intervention_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @group_intervention_nature = GroupInterventionNature.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @group_intervention_nature = GroupInterventionNature.find(params[:id])
    respond_to do |format|
      if @group_intervention_nature.update_attributes(params[:group_intervention_nature])
        format.html { redirect_to (params[:redirect] || @group_intervention_nature) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @group_intervention_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @group_intervention_nature = GroupInterventionNature.find(params[:id])
    @group_intervention_nature.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || group_intervention_natures_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
