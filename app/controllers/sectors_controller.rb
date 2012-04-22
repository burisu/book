# encoding: UTF-8
class SectorsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all sectors
  list :conditions => light_search_conditions(:sectors => [:name, :code, :description]) do |t|
    t.column :name, :url => true
    t.column :code
    t.column :description
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all activities of one sector
  list(:activities, :conditions => ['sector_id = ?', ['session[:current_sector_id]']]) do |t|
    t.column :label, :url => true
    t.column :name
    t.column :code
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def show
    @sector = Sector.find(params[:id])
    session[:current_sector_id] = @sector.id
  end
  
  def new
    @sector = Sector.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @sector }
      format.xml  { render :xml => @sector }
    end
  end
  
  def create
    @sector = Sector.new(params[:sector])
    respond_to do |format|
      if @sector.save
        format.html { redirect_to @sector }
        format.json { render json => @sector, :status => :created, :location => @sector }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @sector.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @sector = Sector.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @sector = Sector.find(params[:id])
    respond_to do |format|
      if @sector.update_attributes(params[:sector])
        format.html { redirect_to @sector }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @sector.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @sector = Sector.find(params[:id])
    @sector.destroy
    respond_to do |format|
      format.html { redirect_to sectors_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
