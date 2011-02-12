# -*- coding: utf-8 -*-
class PaymentsController < ApplicationController

  dyta :payments, :order=>"id DESC" do |t|
    t.column :number
    t.column :label, :through=>:payer
    t.column :mode
    t.column :received
    t.column :used_amount
    t.column :amount
    t.action :receive, :method=>:post, :if=>"RECORD.mode!='none'"
    t.action :edit
    t.action :destroy, :method=>:delete, :confirm=>:are_you_sure
  end

  def index
  end

  def show
    @payment = Payment.find(params[:id])
  end

  def new
    @payment = Payment.new
    @title = "Nouveau paiement"
    render_form
  end

  def create
    @payment = Payment.new(params[:payment])
    if @payment.save
      redirect_to payments_url
    end
    @title = "Nouveau paiement"
    render_form
  end

  def edit
    @payment = Payment.find(params[:id])
    if @payment.mode != "none"
      redirect_to payment_url(@payment)
      return
    end
    @title = "Choisir le mode de paiement #{@payment.number}"
    render_form
  end

  def update
    @payment = Payment.find(params[:id])
    if @payment.mode != "none"
      redirect_to payment_url(@payment)
      return
    end
    @title = "Choisir le mode de paiement #{@payment.number}"
    if @payment.update_attribute(:mode, params[:payment][:mode])
      case @payment.mode.to_sym
      when :cash, :check
        flash[:notice] = "Votre commande a été prise en compte. Veuillez effectuer votre paiement dans les plus brefs délais."
        Maily.deliver_notification(:waiting_payment, @current_person) if @current_person
        redirect_to payment_url(@payment)
      when :card
        redirect_to :controller=>"modulev3.cgi", :PBX_MODE=>1, :PBX_SITE=>"0840363", :PBX_RANG=>"01", :PBX_IDENTIFIANT=>"315034123", :PBX_TOTAL=>(@payment.amount*100).to_i, :PBX_DEVISE=>978, :PBX_CMD=>@payment.number, :PBX_PORTEUR=>@payment.payer_email, :PBX_RETOUR=>Payment.transaction_columns.collect{|k,v| "#{v}:#{v}"}.join(";"), :PBX_LANGUE=>"FRA", :PBX_EFFECTUE=>url_for(:controller=>:store, :action=>:finished), :PBX_REFUSE=>url_for(:controller=>:store, :action=>:refused), :PBX_ANNULE=>url_for(:controller=>:store, :action=>:cancelled)
      end
    end
    render_form
  end

  def destroy
    Payment.find(params[:id]).destroy
    redirect_to payments_url
  end

  def receive
    @payment = Payment.find(params[:id])
    if @payment.mode != "none"
      @payment.received = !@payment.received
      @payment.save
    end
    redirect_to payments_url
  end

end
