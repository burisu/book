# encoding: UTF-8
class SaleLinesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all sale_lines
  list(:conditions => light_search_conditions(:sale_lines => [:sale_id, :product_id, :name, :description, :unit_amount, :quantity, :amount])) do |t|
    t.column :number, :through => :sale, :url => true
    t.column :name, :through => :product, :url => true
    t.column :name, :url => true
    t.column :description
    t.column :unit_amount
    t.column :quantity
    t.column :amount
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all guests of one sale_line
  list(:guests, :conditions => ['sale_line_id = ?', ['session[:current_sale_line_id]']]) do |t|
    t.column :number, :through => :sale, :url => true
    t.column :name, :through => :product, :url => true
    t.column :first_name
    t.column :last_name
    t.column :email
    t.column :name, :through => :zone, :url => true
    t.column :annotation
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @sale_line = SaleLine.find(params[:id])
    session[:current_sale_line_id] = @sale_line.id
  end
  
  def new
    @sale_line = SaleLine.new(:product_id => params[:product_id].to_i, :sale_id => params[:sale_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @sale_line }
      format.xml  { render :xml => @sale_line }
    end
  end
  
  def create
    @sale_line = SaleLine.new(params[:sale_line])
    respond_to do |format|
      if @sale_line.save
        format.html { redirect_to (params[:redirect] || @sale_line) }
        format.json { render json => @sale_line, :status => :created, :location => @sale_line }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @sale_line.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @sale_line = SaleLine.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @sale_line = SaleLine.find(params[:id])
    respond_to do |format|
      if @sale_line.update_attributes(params[:sale_line])
        format.html { redirect_to (params[:redirect] || @sale_line) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @sale_line.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @sale_line = SaleLine.find(params[:id])
    @sale_line.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || sale_lines_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
