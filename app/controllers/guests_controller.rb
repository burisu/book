# encoding: UTF-8
class GuestsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all guests
  list(:conditions => light_search_conditions(:guests => [:sale_line_id, :sale_id, :product_id, :first_name, :last_name, :email, :zone_id, :annotation])) do |t|
    t.column :name, :through => :sale_line, :url => true
    t.column :number, :through => :sale, :url => true
    t.column :name, :through => :product, :url => true
    t.column :first_name
    t.column :last_name
    t.column :email
    t.column :name, :through => :zone, :url => true
    t.column :annotation
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @guest = Guest.find(params[:id])
    session[:current_guest_id] = @guest.id
  end
  
  def new
    @guest = Guest.new(:product_id => params[:product_id].to_i, :sale_id => params[:sale_id].to_i, :sale_line_id => params[:sale_line_id].to_i, :zone_id => params[:zone_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @guest }
      format.xml  { render :xml => @guest }
    end
  end
  
  def create
    @guest = Guest.new(params[:guest])
    respond_to do |format|
      if @guest.save
        format.html { redirect_to (params[:redirect] || @guest) }
        format.json { render json => @guest, :status => :created, :location => @guest }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @guest.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @guest = Guest.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @guest = Guest.find(params[:id])
    respond_to do |format|
      if @guest.update_attributes(params[:guest])
        format.html { redirect_to (params[:redirect] || @guest) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @guest.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @guest = Guest.find(params[:id])
    @guest.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || guests_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
