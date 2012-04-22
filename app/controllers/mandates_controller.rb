# encoding: UTF-8
class MandatesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all mandates
  list :conditions => light_search_conditions(:mandates => [:dont_expire, :started_on, :stopped_on, :nature_id, :person_id, :group_id]) do |t|
    t.column :dont_expire
    t.column :started_on
    t.column :stopped_on
    t.column :name, :through => :nature, :url => true
    t.column :label, :through => :person, :url => true
    t.column :name, :through => :group, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @mandate = Mandate.find(params[:id])
    session[:current_mandate_id] = @mandate.id
  end
  
  def new
    @mandate = Mandate.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @mandate }
      format.xml  { render :xml => @mandate }
    end
  end
  
  def create
    @mandate = Mandate.new(params[:mandate])
    respond_to do |format|
      if @mandate.save
        format.html { redirect_to @mandate }
        format.json { render json => @mandate, :status => :created, :location => @mandate }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @mandate.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @mandate = Mandate.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @mandate = Mandate.find(params[:id])
    respond_to do |format|
      if @mandate.update_attributes(params[:mandate])
        format.html { redirect_to @mandate }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @mandate.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @mandate = Mandate.find(params[:id])
    @mandate.destroy
    respond_to do |format|
      format.html { redirect_to mandates_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
