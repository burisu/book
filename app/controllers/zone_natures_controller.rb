# encoding: UTF-8
class ZoneNaturesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all zone_natures
  list :conditions => light_search_conditions(:zone_natures => [:name, :parent_id]) do |t|
    t.column :name, :url => true
    t.column :name, :through => :parent, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all children of one zone_nature
  list(:children, :model => 'ZoneNature', :conditions => ['parent_id = ?', ['session[:current_zone_nature_id]']]) do |t|
    t.column :name, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  # List all groups of one zone_nature
  list(:groups, :conditions => ['zone_nature_id = ?', ['session[:current_zone_nature_id]']]) do |t|
    t.column :name, :url => true
    t.column :number
    t.column :code
    t.column :name, :through => :parent, :url => true
    t.column :country
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def show
    @zone_nature = ZoneNature.find(params[:id])
    session[:current_zone_nature_id] = @zone_nature.id
  end
  
  def new
    @zone_nature = ZoneNature.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @zone_nature }
      format.xml  { render :xml => @zone_nature }
    end
  end
  
  def create
    @zone_nature = ZoneNature.new(params[:zone_nature])
    respond_to do |format|
      if @zone_nature.save
        format.html { redirect_to @zone_nature }
        format.json { render json => @zone_nature, :status => :created, :location => @zone_nature }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @zone_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @zone_nature = ZoneNature.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @zone_nature = ZoneNature.find(params[:id])
    respond_to do |format|
      if @zone_nature.update_attributes(params[:zone_nature])
        format.html { redirect_to @zone_nature }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @zone_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @zone_nature = ZoneNature.find(params[:id])
    @zone_nature.destroy
    respond_to do |format|
      format.html { redirect_to zone_natures_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
