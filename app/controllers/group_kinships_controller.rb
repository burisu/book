# encoding: UTF-8
class GroupKinshipsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all group_kinships
  list(:conditions => light_search_conditions(:group_kinships => [:parent_id, :child_id, :organization_id])) do |t|
    t.column :name, :through => :parent, :url => true
    t.column :name, :through => :child, :url => true
    t.column :name, :through => :organization, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @group_kinship = GroupKinship.find(params[:id])
    session[:current_group_kinship_id] = @group_kinship.id
  end
  
  def new
    @group_kinship = GroupKinship.new(:organization_id => params[:organization_id].to_i, :parent_id => params[:parent_id].to_i, :child_id => params[:child_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @group_kinship }
      format.xml  { render :xml => @group_kinship }
    end
  end
  
  def create
    @group_kinship = GroupKinship.new(params[:group_kinship])
    respond_to do |format|
      if @group_kinship.save
        format.html { redirect_to (params[:redirect] || @group_kinship) }
        format.json { render json => @group_kinship, :status => :created, :location => @group_kinship }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @group_kinship.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @group_kinship = GroupKinship.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @group_kinship = GroupKinship.find(params[:id])
    respond_to do |format|
      if @group_kinship.update_attributes(params[:group_kinship])
        format.html { redirect_to (params[:redirect] || @group_kinship) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @group_kinship.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @group_kinship = GroupKinship.find(params[:id])
    @group_kinship.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || group_kinships_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
