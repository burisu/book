class PaymentsController < ApplicationController

  def index
  end

  def show
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
    @title = "Modifier le paiement #{@payment.name}"
    render_form
  end

  def update
    @payment = Payment.find(params[:id])
    @title = "Modifier le paiement #{@payment.name}"
    if @payment.update_attributes(params[:payment])
      redirect_to payments_url
    end
    render_form
  end

  def destroy
    Payment.find(params[:id]).destroy
    redirect_to payments_url
  end
end
