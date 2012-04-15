class ProductsController < ApplicationController

  def index
  end
  
  def check
    for product in Product.storables
      product.refresh_stock
    end
    redirect_to products_url
  end

  def new
    @product = Product.new(:password=>Person.generate_password(8).upper)
    @title = "Nouveau produit"
    render_form
  end

  def create
    @product = Product.new(params[:product])
    if @product.save
      redirect_to products_url
    end
    @title = "Nouveau produit"
    render_form
  end

  def edit
    @product = Product.find(params[:id])
    @title = "Modifier le produit #{@product.name}"
    render_form
  end

  def update
    @product = Product.find(params[:id])
    @title = "Modifier le produit #{@product.name}"
    if @product.update_attributes(params[:product])
      redirect_to products_url
    end
    render_form
  end

  def destroy
    Product.find(params[:id]).destroy
    redirect_to products_url
  end

end
