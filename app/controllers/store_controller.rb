class StoreController < ApplicationController

  before_filter :check

  def index

    if request.post?
      redirect_to :controller=>"modulev3.cgi", :PBX_MODE=>1, :PBX_SITE=>"0840363", :PBX_RANG=>"01", :PBX_IDENTIFIANT=>"315034123", :PBX_TOTAL=>1100*params[:duration].to_i, :PBX_DEVISE=>978, :PBX_CMD=>1, :PBX_PORTEUR=>@current_person.email, :PBX_RETOUR=>"montant:M;ref:R;auto:A;trans:T"
    end
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
