class ProductsController < ApplicationController
  
  before_filter :authorize

  def index
  end

  def new
    @product = Product.new
    render_form
  end

  def create
    @product = Product.new(params[:product])
    if @product.save
      redirect_to products_url
    end
    render_form
  end

  def edit
    @product = Product.find(params[:id])
    render_form
  end

  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      redirect_to products_url
    end
    render_form
  end

  def destroy
    Product.find(params[:id]).destroy
  end

end
