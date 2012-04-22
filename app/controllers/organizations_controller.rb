# encoding: UTF-8
class OrganizationsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all organizations
  list :conditions => light_search_conditions(:organizations => [:name, :description, :comment]) do |t|
    t.column :name, :url => true
    t.column :description
    t.column :comment
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all group_natures of one organization
  list(:group_natures, :conditions => ['organization_id = ?', ['session[:current_organization_id]']]) do |t|
    t.column :name, :url => true
    t.column :name, :through => :zone_nature, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  # List all group_kinships of one organization
  list(:group_kinships, :conditions => ['organization_id = ?', ['session[:current_organization_id]']]) do |t|
    t.column :id, :through => :parent, :url => true
    t.column :id, :through => :child, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def show
    @organization = Organization.find(params[:id])
    session[:current_organization_id] = @organization.id
  end
  
  def new
    @organization = Organization.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @organization }
      format.xml  { render :xml => @organization }
    end
  end
  
  def create
    @organization = Organization.new(params[:organization])
    respond_to do |format|
      if @organization.save
        format.html { redirect_to @organization }
        format.json { render json => @organization, :status => :created, :location => @organization }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @organization.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @organization = Organization.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @organization = Organization.find(params[:id])
    respond_to do |format|
      if @organization.update_attributes(params[:organization])
        format.html { redirect_to @organization }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @organization.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
