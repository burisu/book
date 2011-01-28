class SalesController < ApplicationController

  def index
  end

  def new
    @sale = Sale.new
    @title = "Nouvelle vente"
    render_form
  end

  def create
    @sale = Sale.new(params[:sale])
    if @sale.save
      redirect_to sales_url
    end
    @title = "Nouvelle vente"
    render_form
  end

  def edit
    @sale = Sale.find_by_number(params[:id])
    @title = "Modifier la vente #{@sale.name}"
    render_form
  end

  def update
    @sale = Sale.find_by_number(params[:id])
    @title = "Modifier la vente #{@sale.name}"
    if @sale.update_attributes(params[:sale])
      redirect_to sales_url
    end
    render_form
  end

  def destroy
    Sale.find_by_number(params[:id]).destroy
    redirect_to sales_url
  end

end
