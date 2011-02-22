class SalesController < ApplicationController

  dyta(:sales) do |t|
    t.column :number, :url=>{:action=>:show}
    t.column :label, :through=>:client, :url=>{:controller=>:people, :action=>:show}
    t.column :client_email
    t.column :comment
    t.column :state
    t.column :payment_mode
    t.column :payment_number
  end

  def index
  end

  dyta(:sale_lines, :conditions=>{:sale_id=>['session[:current_sale_id]']}, :export=>false) do |t|
    t.column :name
    t.column :description
    t.column :quantity
    t.column :unit_amount
    t.column :amount
  end

  def show
    @sale = Sale.find_by_number(params[:id])
    session[:current_sale_id] = @sale.id
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
    if params[:mode] == "refill"
      @sale.state = "I"
      @sale.save
    end
    @badpass = []
    if @sale.state == "C"
      @sale.save
      redirect_to pay_sale_url(@sale)
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
        @sale.save
        for line in @sale.lines
          line.destroy if line.quantity.zero?
        end
        redirect_to pay_sale_url(@sale)
      end
    end
  end
  
  def pay
    @sale = Sale.find_by_number(params[:id])
    if @sale.state != "C"
      redirect_to (@sale.state == "P" ? sale_url(@sale) : fill_sale_url(@sale))
      return
    end
    if request.post?
      if @sale.update_attribute(:payment_mode, params[:sale][:payment_mode])
        case @sale.payment_mode.to_sym
        when :cash, :check
          flash[:notice] = "Votre commande a été prise en compte. Veuillez effectuer votre paiement dans les plus brefs délais."
          Maily.deliver_notification(:waiting_sale, @current_person) if @current_person
          redirect_to sale_url(@sale)
        when :card
          redirect_to :controller=>"modulev3.cgi", :PBX_MODE=>1, :PBX_SITE=>"0840363", :PBX_RANG=>"01", :PBX_IDENTIFIANT=>"315034123", :PBX_TOTAL=>(@sale.amount*100).to_i, :PBX_DEVISE=>978, :PBX_CMD=>@sale.number, :PBX_PORTEUR=>@sale.client_email, :PBX_RETOUR=>Sale.transaction_columns.collect{|k,v| "#{v}:#{v}"}.join(";"), :PBX_LANGUE=>"FRA", :PBX_EFFECTUE=>url_for(:controller=>:store, :action=>:finished), :PBX_REFUSE=>url_for(:controller=>:store, :action=>:refused), :PBX_ANNULE=>url_for(:controller=>:store, :action=>:cancelled)
        end
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
