class StoreController < ApplicationController

  before_filter :check

  def index
    @unit_price = conf.subscription_price
    @start = @current_person.first_day_as_non_subscriber
    if request.post?
      duration = params[:duration].to_i
      if duration <= 0
        flash.now[:error] = "Attention le nombre d'années doit être strictement positif"
        return
      end
      @subscription = Subscription.create!(:person_id=>@current_person.id, :payment_mode=>"card", :begun=>@start, :finshed_on=>@start+duration.years-1, :amount=>duration*@unit_price)
      redirect_to :action=>:summary, :id=>@subscription.id
    end
  end

  def summary
    unless @subscription = Susbcription.find_by_id(params[:id])
      flash[:error] = "Une errreur est survénue lors de la précédente opération. Veuillez réeessayer."
      redirect_to :action=>:index
      return 
    end
    if @subscription.paid?
      flash[:error] = "Cette commande a déjà été réglée."
      redirect_to :action=>:index
      return 
    end
    if request.post?
      redirect_to :controller=>"modulev3.cgi", :PBX_MODE=>1, :PBX_SITE=>"0840363", :PBX_RANG=>"01", :PBX_IDENTIFIANT=>"315034123", :PBX_TOTAL=>(@unit_price*100).to_i*params[:duration].to_i, :PBX_DEVISE=>978, :PBX_CMD=>1, :PBX_PORTEUR=>@current_person.email, :PBX_RETOUR=>"montant:M;maref:R;auto:A;trans:T;paiement:P;carte:C;idtrans:S;pays:Y;erreur:E;validite:D;IP:I;BIN6:N;sign:K", :PBX_LANGUE=>"FRA", :PBX_EFFECTUE=>url_for(:controller=>:store, :action=>:done), :PBX_REFUSE=>url_for(:controller=>:store, :action=>:refused), :PBX_ANNULE=>url_for(:controller=>:store, :action=>:cancelled)
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

  def done
    flash[:error] = "La transaction a été validée."
    redirect_to :controller=>:intra, :action=>:index
  end

  def check_payment
    flash[:error] = "La transaction a été validée."
    redirect_to :controller=>:intra, :action=>:index
  end


  protected

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
