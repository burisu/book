# -*- coding: utf-8 -*-
class PromotionsController < ApplicationController

  dyta(:people, :model=>:people, :order=>"family_name, first_name", :conditions=>"(session[:current_promotion_id].blank? ? {} : {:promotion_id=>session[:current_promotion_id]}).merge(:student=>true)", :line_class=>"(RECORD.current? ? 'notice' : '')", :order=>"started_on") do |t|
    t.action :show, :url=>{:controller=>:folders}
    t.column :family_name, :url=>{:controller=>:people, :action=>:show}
    t.column :first_name, :url=>{:controller=>:people, :action=>:show}
    t.column :code, :through=>:promotion
    t.column :started_on, :label=>"Du"
    t.column :stopped_on, :label=>"Au"
    t.column :name, :through=>:proposer_zone, :url=>{:controller=>:zones, :action=>:show}
    t.column :name, :through=>:departure_country
    t.column :name, :through=>:arrival_country
    t.action :folder_delete, :method=>:delete, :confirm=>:are_you_sure, :if=>'!RECORD.student'
  end


  def index
    session[:current_promotion_id] = params[:id]
    @promotion = Promotion.find_by_id(session[:current_promotion_id]) unless session[:current_promotion_id].blank?
  end

  def show
    redirect_to promotions_url(:promotion_id=>params[:id])
  end


  def write
    if request.xhr?
      render :inline=>"<%=options_for_select(Promotion.find(:all, :conditions=>['id IN (SELECT promotion_id FROM people WHERE arrival_country_id=?)', params[:country_id]], :order=>:name).collect{|p| [p.name, p.id]}.insert(0, ['-- Toutes les promotions --', '']))-%>"
    else
      @countries = Country.find(:all, :conditions=>["id IN (SELECT arrival_country_id from people)"], :order=>:name)
      @promotions = Promotion.find(:all, :conditions=>['id IN (SELECT promotion_id FROM people WHERE arrival_country_id=?)', @countries[0].id], :order=>:name) # , :conditions=>{:is_outbound=>true}
      if request.post?
        begin
          Maily.deliver_message(@current_person, params[:mail])
          flash[:notice] = 'Votre message a été envoyé.'
          redirect_to myself_url
        rescue
          flash[:error] = "Votre message n'a pas pu être envoyé."
        end
      end
    end
  end



end
