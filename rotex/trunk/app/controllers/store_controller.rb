class StoreController < ApplicationController
  ssl_required :index, :summary, :cancelled, :refused, :finished

  before_filter :check, :except=>:check_payment

  def index
    @unit_price = conf.subscription_price
    @start = @current_person.first_day_as_non_subscriber
    @conf = conf
    if request.post?
      duration = params[:duration].to_i
      if duration <= 0
        flash.now[:error] = "Attention le nombre d'années doit être strictement positif"
        return
      end
      @subscription = Subscription.create!(:person_id=>@current_person.id, :payment_mode=>"card", :begun_on=>@start, :finished_on=>@start+duration.years-1, :amount=>duration*@unit_price, :state=>"I")
      redirect_to :action=>:summary, :id=>@subscription.id
    else
      Subscription.delete_all(:person_id=>@current_person.id, :state=>'I')
    end
  end



  def summary
    unless @subscription = Subscription.find_by_id(params[:id])
      flash[:error] = "Une erreur est survenue lors de la précédente opération. Veuillez réessayer. (#{params[:id]})"
      redirect_to :action=>:index
      return 
    end
    if @subscription.paid?
      flash[:error] = "Cette commande a déjà été réglée."
      redirect_to :action=>:index
      return 
    end
    if request.post?
      @subscription.payment_mode = params[:subscription][:payment_mode]
      @subscription.save!
      @subscription.confirm
      case @subscription.payment_mode.to_sym
      when :cash, :check
        flash[:notice] = "Votre commande a été prise en compte. Veuillez effectuer votre paiement dans les plus brefs délais."
        Maily.deliver_notification(:waiting_payment, @current_person)
        redirect_to :action=>:index
      when :card
        redirect_to :controller=>"modulev3.cgi", :PBX_MODE=>1, :PBX_SITE=>"0840363", :PBX_RANG=>"01", :PBX_IDENTIFIANT=>"315034123", :PBX_TOTAL=>(@subscription.amount*100).to_i, :PBX_DEVISE=>978, :PBX_CMD=>@subscription.number, :PBX_PORTEUR=>@current_person.email, :PBX_RETOUR=>Subscription.transaction_columns.collect{|k,v| "#{v}:#{v}"}.join(";"), :PBX_LANGUE=>"FRA", :PBX_EFFECTUE=>url_for(:controller=>:store, :action=>:finished), :PBX_REFUSE=>url_for(:controller=>:store, :action=>:refused), :PBX_ANNULE=>url_for(:controller=>:store, :action=>:cancelled)
      end
    end
  end

  def cancelled
    flash[:warning] = "La transaction a été annulée."
    redirect_to :action=>:index
  end

  def refused
    flash[:error] = "La transaction a été refusée."
    redirect_to :action=>:index
  end

  def finished
    validate_payment
    redirect_to :controller=>:intra, :action=>:index
  end

  def check_payment
    validate_payment(true)
    render :text=>""
  end

  protected

  def validate_payment(no_redirect = false)
    unless @subscription = Subscription.find_by_number(params["R"])
      flash[:error] = "Une erreur est survenue lors de la précédente opération. Veuillez réeessayer."
      redirect_to :action=>:index unless no_redirect
      return 
    end
    if @subscription.state != "P" and @subscription.payment_mode == "card"
      for k, v in Subscription.transaction_columns.delete_if{|k,v| [:amount, :number].include? k}
        @subscription.send("#{k}=", params[v])
      end
      @subscription.responsible = @current_person
      @subscription.save
      if error_code == "00000"
        flash[:notice] = "La transaction a été validée."
        @subscription.terminate 
      else
        flash[:error] = "Une erreur s'est produite #{@subscription.error_message}"
      end
    end    
  end

  def check
    unless session[:current_person_id]
      session[:last_url] = request.url
      session[:original_uri] = request.request_uri
      flash[:warning] = "Vous devez vous connecter pour accéder au paiement en ligne"
      redirect_to :controller=>:authentication, :action=>:login
      return
    end
    session[:last_request] ||= Time.now.to_i
    if Time.now.to_i-session[:last_request]>3600
      reset_session
      flash[:warning] = 'La session est expirée. Veuillez vous reconnecter.'
      redirect_to :controller=>:authentication, :action=>:login
      return
    end
  end

end
