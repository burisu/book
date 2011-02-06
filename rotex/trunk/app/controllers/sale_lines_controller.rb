class SaleLinesController < ApplicationController
  
  before_filter :find

  def new
    @sale_line = SaleLine.new
    @title = "Nouvelle vente"
    render_form
  end

  def create
    @sale_line = SaleLine.new(params[:sale_line])
    if @sale_line.save
      redirect_to sale_url(@sale)
    end
    @title = "Nouvelle ligne de vente"
    render_form
  end

  def edit
    return unless @sale_line = SaleLine.find_by_id_and_sale_id(params[:id], @sale.id)
    @title = "Modifier la vente #{@sale_line.id}"
    render_form
  end

  def update
    return unless @sale_line = SaleLine.find_by_id_and_sale_id(params[:id], @sale.id)
    @title = "Modifier la vente #{@sale_line.id}"
    if @sale_line.update_attributes(params[:sale_line])
      redirect_to sale_url(@sale)
    end
    render_form
  end

  def destroy
    return unless @sale_line = SaleLine.find_by_id_and_sale_id(params[:id], @sale.id)
    @sale_line.destroy
    redirect_to sale_url(@sale)
  end

  protected

  def find()
    raise "Stop" unless @sale = Sale.find_by_number(params[:id])
  end

end
