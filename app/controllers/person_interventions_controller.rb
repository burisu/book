# encoding: UTF-8
class PersonInterventionsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all person_interventions
  list :conditions => light_search_conditions(:person_interventions => [:nature_id, :person_id, :event_id, :group_intervention_id, :started_at, :stopped_at, :description, :comment]) do |t|
    t.column :name, :through => :nature, :url => true
    t.column :label, :through => :person, :url => true
    t.column :name, :through => :event, :url => true
    t.column :description, :through => :group_intervention, :url => true
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
    @person_intervention = PersonIntervention.find(params[:id])
    session[:current_person_intervention_id] = @person_intervention.id
  end
  
  def new
    @person_intervention = PersonIntervention.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @person_intervention }
      format.xml  { render :xml => @person_intervention }
    end
  end
  
  def create
    @person_intervention = PersonIntervention.new(params[:person_intervention])
    respond_to do |format|
      if @person_intervention.save
        format.html { redirect_to @person_intervention }
        format.json { render json => @person_intervention, :status => :created, :location => @person_intervention }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @person_intervention.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @person_intervention = PersonIntervention.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @person_intervention = PersonIntervention.find(params[:id])
    respond_to do |format|
      if @person_intervention.update_attributes(params[:person_intervention])
        format.html { redirect_to @person_intervention }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @person_intervention.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @person_intervention = PersonIntervention.find(params[:id])
    @person_intervention.destroy
    respond_to do |format|
      format.html { redirect_to person_interventions_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
