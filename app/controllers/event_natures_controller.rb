# encoding: UTF-8
class EventNaturesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all event_natures
  list(:conditions => light_search_conditions(:event_natures => [:name, :comment])) do |t|
    t.column :name, :url => true
    t.column :comment
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all events of one event_nature
  list(:events, :conditions => ['nature_id = ?', ['session[:current_event_nature_id]']]) do |t|
    t.column :name, :url => true
    t.column :place
    t.column :description
    t.column :comment
    t.column :started_at
    t.column :stopped_at
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @event_nature = EventNature.find(params[:id])
    session[:current_event_nature_id] = @event_nature.id
  end
  
  def new
    @event_nature = EventNature.new()
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @event_nature }
      format.xml  { render :xml => @event_nature }
    end
  end
  
  def create
    @event_nature = EventNature.new(params[:event_nature])
    respond_to do |format|
      if @event_nature.save
        format.html { redirect_to (params[:redirect] || @event_nature) }
        format.json { render json => @event_nature, :status => :created, :location => @event_nature }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @event_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @event_nature = EventNature.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @event_nature = EventNature.find(params[:id])
    respond_to do |format|
      if @event_nature.update_attributes(params[:event_nature])
        format.html { redirect_to (params[:redirect] || @event_nature) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @event_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @event_nature = EventNature.find(params[:id])
    @event_nature.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || event_natures_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
