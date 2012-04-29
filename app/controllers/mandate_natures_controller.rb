# encoding: UTF-8
class MandateNaturesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all mandate_natures
  list(:conditions => light_search_conditions(:mandate_natures => [:name, :rights, :group_nature_id])) do |t|
    t.column :name, :url => true
    t.column :rights
    t.column :name, :through => :group_nature, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all mandates of one mandate_nature
  list(:mandates, :conditions => ['nature_id = ?', ['session[:current_mandate_nature_id]']]) do |t|
    t.column :dont_expire
    t.column :started_on
    t.column :stopped_on
    t.column :label, :through => :person, :url => true
    t.column :name, :through => :group, :url => true
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @mandate_nature = MandateNature.find(params[:id])
    session[:current_mandate_nature_id] = @mandate_nature.id
  end
  
  def new
    @mandate_nature = MandateNature.new(:group_nature_id => params[:group_nature_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @mandate_nature }
      format.xml  { render :xml => @mandate_nature }
    end
  end
  
  def create
    @mandate_nature = MandateNature.new(params[:mandate_nature])
    respond_to do |format|
      if @mandate_nature.save
        format.html { redirect_to (params[:redirect] || @mandate_nature) }
        format.json { render json => @mandate_nature, :status => :created, :location => @mandate_nature }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @mandate_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @mandate_nature = MandateNature.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @mandate_nature = MandateNature.find(params[:id])
    respond_to do |format|
      if @mandate_nature.update_attributes(params[:mandate_nature])
        format.html { redirect_to (params[:redirect] || @mandate_nature) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @mandate_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @mandate_nature = MandateNature.find(params[:id])
    @mandate_nature.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || mandate_natures_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
