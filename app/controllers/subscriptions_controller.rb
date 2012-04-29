# encoding: UTF-8
class SubscriptionsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all subscriptions
  list(:conditions => light_search_conditions(:subscriptions => [:begun_on, :finished_on, :person_id, :number, :sale_id, :sale_line_id])) do |t|
    t.column :begun_on
    t.column :finished_on
    t.column :label, :through => :person, :url => true
    t.column :number, :url => true
    t.column :number, :through => :sale, :url => true
    t.column :name, :through => :sale_line, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @subscription = Subscription.find(params[:id])
    session[:current_subscription_id] = @subscription.id
  end
  
  def new
    @subscription = Subscription.new(:person_id => params[:person_id].to_i, :sale_id => params[:sale_id].to_i, :sale_line_id => params[:sale_line_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @subscription }
      format.xml  { render :xml => @subscription }
    end
  end
  
  def create
    @subscription = Subscription.new(params[:subscription])
    respond_to do |format|
      if @subscription.save
        format.html { redirect_to (params[:redirect] || @subscription) }
        format.json { render json => @subscription, :status => :created, :location => @subscription }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @subscription.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @subscription = Subscription.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @subscription = Subscription.find(params[:id])
    respond_to do |format|
      if @subscription.update_attributes(params[:subscription])
        format.html { redirect_to (params[:redirect] || @subscription) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @subscription.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @subscription = Subscription.find(params[:id])
    @subscription.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || subscriptions_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
