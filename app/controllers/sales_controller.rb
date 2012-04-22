# encoding: UTF-8
class SalesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all sales
  list :conditions => light_search_conditions(:sales => [:number, :state, :comment, :client_id, :client_email, :amount, :created_on, :sequential_number, :authorization_number, :payment_type, :card_type, :transaction_number, :country, :error_code, :card_expired_on, :payer_country, :signature, :bin6, :payment_mode, :payment_number]) do |t|
    t.column :number, :url => true
    t.column :state
    t.column :comment
    t.column :label, :through => :client, :url => true
    t.column :client_email
    t.column :amount
    t.column :created_on
    t.column :sequential_number
    t.column :authorization_number
    t.column :payment_type
    t.column :card_type
    t.column :transaction_number
    t.column :country
    t.column :error_code
    t.column :card_expired_on
    t.column :payer_country
    t.column :signature
    t.column :bin6
    t.column :payment_mode
    t.column :payment_number
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all guests of one sale
  list(:guests, :conditions => ['sale_id = ?', ['session[:current_sale_id]']]) do |t|
    t.column :name, :through => :sale_line, :url => true
    t.column :name, :through => :product, :url => true
    t.column :first_name
    t.column :last_name
    t.column :email
    t.column :name, :through => :zone, :url => true
    t.column :annotation
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  # List all lines of one sale
  list(:lines, :model => 'SaleLine', :conditions => ['sale_id = ?', ['session[:current_sale_id]']]) do |t|
    t.column :name, :through => :product, :url => true
    t.column :name, :url => true
    t.column :description
    t.column :unit_amount
    t.column :quantity
    t.column :amount
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  # List all passworded_lines of one sale
  list(:passworded_lines, :model => 'SaleLine', :conditions => ['sale_id = ?', ['session[:current_sale_id]']]) do |t|
    t.column :name, :through => :product, :url => true
    t.column :name, :url => true
    t.column :description
    t.column :unit_amount
    t.column :quantity
    t.column :amount
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  # List all subscriptions of one sale
  list(:subscriptions, :conditions => ['sale_id = ?', ['session[:current_sale_id]']]) do |t|
    t.column :begun_on
    t.column :finished_on
    t.column :label, :through => :person, :url => true
    t.column :number, :url => true
    t.column :name, :through => :sale_line, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def show
    @sale = Sale.find(params[:id])
    session[:current_sale_id] = @sale.id
  end
  
  def new
    @sale = Sale.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @sale }
      format.xml  { render :xml => @sale }
    end
  end
  
  def create
    @sale = Sale.new(params[:sale])
    respond_to do |format|
      if @sale.save
        format.html { redirect_to @sale }
        format.json { render json => @sale, :status => :created, :location => @sale }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @sale.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @sale = Sale.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @sale = Sale.find(params[:id])
    respond_to do |format|
      if @sale.update_attributes(params[:sale])
        format.html { redirect_to @sale }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @sale.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @sale = Sale.find(params[:id])
    @sale.destroy
    respond_to do |format|
      format.html { redirect_to sales_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
