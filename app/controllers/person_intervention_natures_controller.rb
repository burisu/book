# encoding: UTF-8
class PersonInterventionNaturesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all person_intervention_natures
  list(:conditions => light_search_conditions(:person_intervention_natures => [:name, :description, :comment])) do |t|
    t.column :name, :url => true
    t.column :description
    t.column :comment
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all person_interventions of one person_intervention_nature
  list(:person_interventions, :conditions => ['nature_id = ?', ['session[:current_person_intervention_nature_id]']]) do |t|
    t.column :label, :through => :person, :url => true
    t.column :name, :through => :event, :url => true
    t.column :description, :through => :group_intervention, :url => true
    t.column :started_at
    t.column :stopped_at
    t.column :description, :url => true
    t.column :comment
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @person_intervention_nature = PersonInterventionNature.find(params[:id])
    session[:current_person_intervention_nature_id] = @person_intervention_nature.id
  end
  
  def new
    @person_intervention_nature = PersonInterventionNature.new()
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @person_intervention_nature }
      format.xml  { render :xml => @person_intervention_nature }
    end
  end
  
  def create
    @person_intervention_nature = PersonInterventionNature.new(params[:person_intervention_nature])
    respond_to do |format|
      if @person_intervention_nature.save
        format.html { redirect_to (params[:redirect] || @person_intervention_nature) }
        format.json { render json => @person_intervention_nature, :status => :created, :location => @person_intervention_nature }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @person_intervention_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @person_intervention_nature = PersonInterventionNature.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @person_intervention_nature = PersonInterventionNature.find(params[:id])
    respond_to do |format|
      if @person_intervention_nature.update_attributes(params[:person_intervention_nature])
        format.html { redirect_to (params[:redirect] || @person_intervention_nature) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @person_intervention_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @person_intervention_nature = PersonInterventionNature.find(params[:id])
    @person_intervention_nature.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || person_intervention_natures_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
