# encoding: UTF-8
class GroupNaturesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all group_natures
  list :conditions => light_search_conditions(:group_natures => [:name, :organization_id, :zone_nature_id]) do |t|
    t.column :name, :url => true
    t.column :name, :through => :organization, :url => true
    t.column :name, :through => :zone_nature, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all groups of one group_nature
  list(:groups, :conditions => ['group_nature_id = ?', ['session[:current_group_nature_id]']]) do |t|
    t.column :name, :url => true
    t.column :number
    t.column :code
    t.column :name, :through => :zone_nature, :url => true
    t.column :name, :through => :parent, :url => true
    t.column :country
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def show
    @group_nature = GroupNature.find(params[:id])
    session[:current_group_nature_id] = @group_nature.id
  end
  
  def new
    @group_nature = GroupNature.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @group_nature }
      format.xml  { render :xml => @group_nature }
    end
  end
  
  def create
    @group_nature = GroupNature.new(params[:group_nature])
    respond_to do |format|
      if @group_nature.save
        format.html { redirect_to @group_nature }
        format.json { render json => @group_nature, :status => :created, :location => @group_nature }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @group_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @group_nature = GroupNature.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @group_nature = GroupNature.find(params[:id])
    respond_to do |format|
      if @group_nature.update_attributes(params[:group_nature])
        format.html { redirect_to @group_nature }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @group_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @group_nature = GroupNature.find(params[:id])
    @group_nature.destroy
    respond_to do |format|
      format.html { redirect_to group_natures_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
