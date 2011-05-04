# -*- coding: utf-8 -*-
class FoldersController < ApplicationController

  def show
    if params[:id].blank? or (not access?(:folders) and params[:id] != session[:current_person_id].to_s)
      flash[:error] = "Vous n'avez pas accès à ce dossier"
      redirect_to :back
      return
    end
    @person = Person.find_by_id(params[:id]) # session[:current_person_id]

    session[:current_folder_id] = @person.id
    @reports = []
    @periods = []
    @reports2 = {}
    session[:periods] ||= {}
    @owner_mode = (session[:current_person_id]==@person.id ? true : false)
    
    if @person
      @reports = @person.reports
      @periods = @person.periods.find(:all, :order=>:begun_on)
    end
    # raise Exception.new @person.inspect
  end


  # def folder_create
  #   unless @current_person.student
  #     flash[:error] = "Vous n'avez pas accès à ce dossier"
  #     redirect_to :back
  #     return
  #   end
  #   @person = @current_person
  #   @person.attributes = params[:person]
  #   @zone_nature = ZoneNature.find(:first, :conditions=>["LOWER(name) LIKE 'club'"])
  #   @zones = Zone.list(["zones.nature_id=?",@zone_nature.id]) # find(:all, :select=>"co.name||' - '||district.name||' - '||zones.name AS long_name, zones.id AS zid", :joins=>" join zones as zse on (zones.parent_id=zse.id) join zones as district on (zse.parent_id=district.id) join countries AS co ON (zones.country_id=co.id)", :conditions=>["zones.nature_id=?",@zone_nature.id], :order=>"co.iso3166, district.name, zones.name").collect {|p| [ p[:long_name], p[:zid].to_i ] }||[]
  #   if @zones.empty?    
  #     flash[:warning] = 'Vous ne pouvez pas modifier votre voyage actuellement. Réessayez plus tard.'
  #     redirect_to myself_url 
  #     return
  #   end
  #   if request.post?
  #     @person.forced = true
  #     if @person.save
  #       redirect_to :action=>:folder, :id=>@person.id
  #       return
  #     end
  #   end
  #   @title = "Enregistrement du voyage"
  #   render_form
  # end


  def edit
    if not access?(:folders) and params[:id].to_i != session[:current_person_id].to_i
      flash[:error] = "Vous n'avez pas accès à ce dossier"
      redirect_to :back
      return
    end
    @person = Person.find(params[:id])
    @zones = Zone.list("club")
    if @zones.empty?    
      flash[:warning] = 'Vous ne pouvez pas modifier votre voyage actuellement. Réessayez plus tard.'
      redirect_to myself_url 
      return
    end
    render_form
  end


  def update
    if not access?(:folders) and params[:id].to_i != session[:current_person_id].to_i
      flash[:error] = "Vous n'avez pas accès à ce dossier"
      redirect_to :back
      return
    end
    @person = Person.find(params[:id])
    @zones = Zone.list("club")
    if @zones.empty?    
      flash[:warning] = 'Vous ne pouvez pas modifier votre voyage actuellement. Réessayez plus tard.'
      redirect_to myself_url 
      return
    end
    @person.attributes = params[:person]
    @person.forced = true
    if @person.save
      redirect_to folder_url(@person)
    end        
    render_form
  end


  def destroy
    person = Person.find_by_id(params[:id])
    person.update_attribute(:promotion_id, nil) unless person.nil?
    redirect_to folders_url
  end



  def report
    session[:no_history] = true
    begin
      year = params[:id].to_s[0..3].to_i
      month = params[:id].to_s[4..-1].to_i
    rescue
      flash[:error] = "Code d'article invalide"
      redirect_to :back
      return
    end
    start = Date.civil(year, month, 1)
    @article = Article.find(:first, :conditions=>{:done_on=>start, :author_id=>session[:current_person_id]})
    if @article
      redirect_to :action=>:article_update, :id=>@article.id
    else
      session[:report_done_on] = start
      redirect_to :action=>:article_create, :rubric_id=>conf.news_rubric_id
    end
  end

end
