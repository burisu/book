# encoding: UTF-8
class HonoursController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all honours
  list :conditions => light_search_conditions(:honours => [:nature_id, :name, :abbreviation, :position]) do |t|
    t.column :name, :through => :nature, :url => true
    t.column :name, :url => true
    t.column :abbreviation
    t.column :position
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @honour = Honour.find(params[:id])
    session[:current_honour_id] = @honour.id
  end
  
  def new
    @honour = Honour.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @honour }
      format.xml  { render :xml => @honour }
    end
  end
  
  def create
    @honour = Honour.new(params[:honour])
    respond_to do |format|
      if @honour.save
        format.html { redirect_to @honour }
        format.json { render json => @honour, :status => :created, :location => @honour }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @honour.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @honour = Honour.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @honour = Honour.find(params[:id])
    respond_to do |format|
      if @honour.update_attributes(params[:honour])
        format.html { redirect_to @honour }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @honour.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @honour = Honour.find(params[:id])
    @honour.destroy
    respond_to do |format|
      format.html { redirect_to honours_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
