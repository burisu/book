class SalesController < ApplicationController

  dyta(:sales) do |t|
    t.column :number, :url=>{:action=>:show}
    t.column :label, :through=>:client, :url=>{:controller=>:intra, :action=>:person}
    t.column :client_email
    t.column :comment
    t.column :state
  end

  def index
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
    @badpass = []
    if @sale.state == "C"
      @sale.create_payment(:amount=>@sale.amount, :mode=>"none", :payer=>@sale.client, :payer_email=>@sale.client_email) unless @sale.payment
      raise @sale.payment.errors.inspect unless @sale.payment.valid?
      redirect_to edit_payment_url(@sale.payment)
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
        @sale.create_payment(:amount=>@sale.amount, :mode=>"none", :payer=>@sale.client, :payer_email=>@sale.client_email)
        redirect_to edit_payment_url(@sale.payment)
      end
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
