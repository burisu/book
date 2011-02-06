class SalesController < ApplicationController


  before_filter :find, :except=>[:index, :new, :create]

  def index
  end


  def show
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

  protected

  def find()
    @sale = nil
    begin
      @sale = Sale.find(params[:id])
    rescue
      flash[:error] = "La vente est introuvable"
      return false
    end
  end


end
