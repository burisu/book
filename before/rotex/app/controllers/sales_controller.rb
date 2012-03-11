# -*- coding: utf-8 -*-
class SalesController < ApplicationController
  # ssl_only

  

  dyta(:sales, :conditions=>search_conditions(:sales, [:number, :payment_number, :payment_mode, :client_email, :comment]), :order=>"id DESC") do |t|
    t.column :id
    t.column :number, :url=>{:action=>:show}
    t.column :label, :through=>:client, :url=>{:controller=>:people, :action=>:show}
    t.column :client_email
    t.column :comment
    t.column :state
    t.column :payment_mode
    t.column :payment_number
    t.action :edit
  end

  def index
    session[:sale_key] = params[:sale_key]||params[:key]
  end

  dyta(:sale_lines, :conditions=>{:sale_id=>['session[:current_sale_id]']}, :export=>false) do |t|
    t.column :name
    t.column :description
    t.column :quantity
    t.column :unit_amount
    t.column :amount
  end

  def show
    @sale = Sale.find_by_number(params[:id])
    session[:current_sale_id] = @sale.id
  end

  def new
    if @current_person
      sale = @current_person.sales.find(:first, :conditions=>{:state=>'I'}, :order=>"id DESC")
      sale ||= Sale.create(:client=>@current_person)
      redirect_to fill_sale_url(sale)
      return
    end
    @sale = Sale.new
    @title = "Nouvelle vente"
    render_form
  end

  def create
    @sale = Sale.new(params[:sale])
    if @sale.save_with_captcha
      redirect_to fill_sale_url(@sale)
    end
    @title = "Nouvelle vente"
    render_form
  end
  
  def fill
    @sale = Sale.find_by_number(params[:id])
    if params[:mode] == "refill"
      @sale.state = "I"
      @sale.save
    end
    @badpass = []
    if @sale.state == "C"
      @sale.save
      redirect_to pay_sale_url(@sale)
      return 
    end
    @title = "Remplissez votre panier #{@sale.number}"
    if request.post?
      for line in @sale.passworded_lines
        if line.product.password != params[:line][line.id.to_s][:password]
          @badpass << line.id
        end
      end
      if @badpass.empty?
        @sale.update_attribute(:state, "C")
        @sale.save
        for line in @sale.lines
          line.destroy if line.quantity.zero?
        end
        redirect_to pay_sale_url(@sale)
      end
    end
  end
  
  def pay
    unless @sale = Sale.find_by_number(params[:id])
      redirect_to new_sale_url
      return
    end
    if @sale.state != "C"
      redirect_to (@sale.state == "P" ? sale_url(@sale) : fill_sale_url(@sale))
      return
    end
    if request.post?
      if params[:sale] and @sale.update_attribute(:payment_mode, params[:sale][:payment_mode])
        case @sale.payment_mode.to_sym
        when :cash, :check
          flash[:notice] = "Votre commande a été prise en compte. Veuillez effectuer votre paiement dans les plus brefs délais."
          Maily.deliver_notification(:waiting_payment, @sale.client || @sale)
          redirect_to sale_url(@sale)
        when :card
          # redirect_to :controller=>"modulev3.cgi", :PBX_MODE=>1, :PBX_SITE=>"0840363", :PBX_RANG=>"01", :PBX_IDENTIFIANT=>"315034123", :PBX_TOTAL=>(@sale.amount*100).to_i, :PBX_DEVISE=>978, :PBX_CMD=>@sale.number, :PBX_PORTEUR=>@sale.client_email, :PBX_RETOUR=>Sale.transaction_columns.collect{|k,v| "#{v}:#{v}"}.join(";"), :PBX_LANGUE=>"FRA", :PBX_EFFECTUE=>finish_sale_url(@sale), :PBX_REFUSE=>refuse_sale_url(@sale), :PBX_ANNULE=>cancel_sale_url(@sale)
          redirect_to URI.encode("https://www.rotex1690.org/site/modulev3.cgi?"+{:PBX_MODE=>1, :PBX_SITE=>"0840363", :PBX_RANG=>"01", :PBX_IDENTIFIANT=>"315034123", :PBX_TOTAL=>(@sale.amount*100).to_i, :PBX_DEVISE=>978, :PBX_CMD=>@sale.number, :PBX_PORTEUR=>@sale.client_email, :PBX_RETOUR=>Sale.transaction_columns.collect{|k,v| "#{v}:#{v}"}.join(";"), :PBX_LANGUE=>"FRA", :PBX_EFFECTUE=>finish_sale_url(@sale), :PBX_REFUSE=>refuse_sale_url(@sale), :PBX_ANNULE=>cancel_sale_url(@sale)}.collect{|k,v| "#{k}=#{v.to_s}"}.join('&'))
        end
      end
    end
  end
  

  def edit
    @sale = Sale.find_by_number(params[:id])
    @title = "Modifier la vente #{@sale.number}"
    render_form :partial=>:edit
  end

  def update
    @sale = Sale.find_by_number(params[:id])
    @title = "Modifier la vente #{@sale.number}"
    if @sale.update_attributes(params[:sale])
      redirect_to sales_url
    end
    render_form :partial=>:edit
  end

  def destroy
    Sale.find_by_number(params[:id]).destroy
    redirect_to sales_url
  end


  def cancel
    flash[:warning] = "La transaction a été annulée."
    sale = Sale.find_by_number(params[:id])
    redirect_to sale_url(sale)
  end

  def refuse
    flash[:error] = "La transaction a été refusée."
    sale = Sale.find_by_number(params[:id])
    redirect_to sale_url(sale)
  end

  def finish
    validate_payment
    sale = Sale.find_by_number(params[:id])
    redirect_to root_url
  end

  def check
    validate_payment(true)
    render :text=>""
  end

  protected

  def validate_payment(no_redirect = false)
    unless @sale = Sale.find_by_number(params["R"])
      flash[:error] = "Une erreur est survenue lors de la précédente opération. Veuillez réeessayer."
      redirect_to root_url unless no_redirect
      return 
    end
    if @sale.payment_mode == "card"
      for k, v in Sale.transaction_columns.delete_if{|k,v| [:amount, :number].include? k}
        @sale.send("#{k}=", params[v])
      end
      @sale.save
      if @sale.error_code == "00000"
        flash[:notice] = "La transaction a été validée."
        @sale.terminate
      else
        flash[:error] = "Une erreur s'est produite #{@sale.error_message}"
      end
    end
  end

end
