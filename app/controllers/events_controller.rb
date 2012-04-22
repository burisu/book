# encoding: UTF-8
class EventsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all events
  list :conditions => light_search_conditions(:events => [:name, :place, :description, :comment, :started_at, :stopped_at, :nature_id]) do |t|
    t.column :name, :url => true
    t.column :place
    t.column :description
    t.column :comment
    t.column :started_at
    t.column :stopped_at
    t.column :name, :through => :nature, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @event = Event.find(params[:id])
    session[:current_event_id] = @event.id
  end
  
  def new
    @event = Event.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @event }
      format.xml  { render :xml => @event }
    end
  end
  
  def create
    @event = Event.new(params[:event])
    respond_to do |format|
      if @event.save
        format.html { redirect_to @event }
        format.json { render json => @event, :status => :created, :location => @event }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @event.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @event = Event.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @event = Event.find(params[:id])
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @event.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
