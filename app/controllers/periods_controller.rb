# encoding: UTF-8
class PeriodsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all periods
  list(:conditions => light_search_conditions(:periods => [:begun_on, :finished_on, :person_id, :comment, :family_name, :address, :latitude, :longitude, :photo, :phone, :fax, :email, :mobile, :country])) do |t|
    t.column :begun_on
    t.column :finished_on
    t.column :label, :through => :person, :url => true
    t.column :comment
    t.column :family_name
    t.column :address
    t.column :latitude
    t.column :longitude
    t.column :photo
    t.column :phone
    t.column :fax
    t.column :email
    t.column :mobile
    t.column :country
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @period = Period.find(params[:id])
    session[:current_period_id] = @period.id
  end
  
  def new
    @period = Period.new(:person_id => params[:person_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @period }
      format.xml  { render :xml => @period }
    end
  end
  
  def create
    @period = Period.new(params[:period])
    respond_to do |format|
      if @period.save
        format.html { redirect_to (params[:redirect] || @period) }
        format.json { render json => @period, :status => :created, :location => @period }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @period.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @period = Period.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @period = Period.find(params[:id])
    respond_to do |format|
      if @period.update_attributes(params[:period])
        format.html { redirect_to (params[:redirect] || @period) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @period.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @period = Period.find(params[:id])
    @period.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || periods_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
