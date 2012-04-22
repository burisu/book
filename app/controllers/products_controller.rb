# encoding: UTF-8
class ProductsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all products
  list :conditions => light_search_conditions(:products => [:name, :description, :amount, :unit, :deadlined, :started_on, :stopped_on, :storable, :initial_quantity, :current_quantity, :subscribing, :subscribing_started_on, :subscribing_stopped_on, :personal, :active, :passworded, :password]) do |t|
    t.column :name, :url => true
    t.column :description
    t.column :amount
    t.column :unit
    t.column :deadlined
    t.column :started_on
    t.column :stopped_on
    t.column :storable
    t.column :initial_quantity
    t.column :current_quantity
    t.column :subscribing
    t.column :subscribing_started_on
    t.column :subscribing_stopped_on
    t.column :personal
    t.column :active
    t.column :passworded
    t.column :password
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all guests of one product
  list(:guests, :conditions => ['product_id = ?', ['session[:current_product_id]']]) do |t|
    t.column :name, :through => :sale_line, :url => true
    t.column :number, :through => :sale, :url => true
    t.column :first_name
    t.column :last_name
    t.column :email
    t.column :name, :through => :zone, :url => true
    t.column :annotation
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  # List all sale_lines of one product
  list(:sale_lines, :conditions => ['product_id = ?', ['session[:current_product_id]']]) do |t|
    t.column :number, :through => :sale, :url => true
    t.column :name, :url => true
    t.column :description
    t.column :unit_amount
    t.column :quantity
    t.column :amount
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  # List all order_lines of one product
  list(:order_lines, :model => 'SaleLine', :conditions => ['product_id = ?', ['session[:current_product_id]']]) do |t|
    t.column :number, :through => :sale, :url => true
    t.column :name, :url => true
    t.column :description
    t.column :unit_amount
    t.column :quantity
    t.column :amount
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def show
    @product = Product.find(params[:id])
    session[:current_product_id] = @product.id
  end
  
  def new
    @product = Product.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @product }
      format.xml  { render :xml => @product }
    end
  end
  
  def create
    @product = Product.new(params[:product])
    respond_to do |format|
      if @product.save
        format.html { redirect_to @product }
        format.json { render json => @product, :status => :created, :location => @product }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @product.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @product = Product.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @product = Product.find(params[:id])
    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to @product }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @product.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
