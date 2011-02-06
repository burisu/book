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
      redirect_to sale_url
    end
    @title = "Nouvelle ligne de vente"
    render_form
  end

  def edit
    @sale_line = SaleLine.find_by_number(params[:id])
    @title = "Modifier la vente #{@sale_line.name}"
    render_form
  end

  def update
    @sale_line = SaleLine.find_by_number(params[:id])
    @title = "Modifier la vente #{@sale_line.name}"
    if @sale_line.update_attributes(params[:sale_line])
      redirect_to sale_url
    end
    render_form
  end

  def destroy
    SaleLine.find_by_number(params[:id]).destroy
    redirect_to sale_url
  end

  def find()
  end

end
