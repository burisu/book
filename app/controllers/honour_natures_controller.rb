# encoding: UTF-8
class HonourNaturesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all honour_natures
  list(:conditions => light_search_conditions(:honour_natures => [:name, :code, :description, :comment])) do |t|
    t.column :name, :url => true
    t.column :code
    t.column :description
    t.column :comment
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all honours of one honour_nature
  list(:honours, :conditions => ['honour_nature_id = ?', ['session[:current_honour_nature_id]']]) do |t|
    t.column :name, :through => :nature, :url => true
    t.column :name, :url => true
    t.column :code
    t.column :abbreviation
    t.column :position
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @honour_nature = HonourNature.find(params[:id])
    session[:current_honour_nature_id] = @honour_nature.id
  end
  
  def new
    @honour_nature = HonourNature.new()
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @honour_nature }
      format.xml  { render :xml => @honour_nature }
    end
  end
  
  def create
    @honour_nature = HonourNature.new(params[:honour_nature])
    respond_to do |format|
      if @honour_nature.save
        format.html { redirect_to (params[:redirect] || @honour_nature) }
        format.json { render json => @honour_nature, :status => :created, :location => @honour_nature }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @honour_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @honour_nature = HonourNature.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @honour_nature = HonourNature.find(params[:id])
    respond_to do |format|
      if @honour_nature.update_attributes(params[:honour_nature])
        format.html { redirect_to (params[:redirect] || @honour_nature) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @honour_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @honour_nature = HonourNature.find(params[:id])
    @honour_nature.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || honour_natures_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
