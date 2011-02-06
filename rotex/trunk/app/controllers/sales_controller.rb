class SalesController < ApplicationController

  def index
    raise params.inspect
  end

  def show
  end

  def new
    if @current_person
      sale = Sale.create(:client=>@current_person)
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
    @title = "Remplissez votre panier #{@sale.number}"
    if request.post?
      
    else
      
    end
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
