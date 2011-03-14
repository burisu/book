# -*- coding: utf-8 -*-
class IntraController < ApplicationController
  ssl_only

  dyli(:authors, [:first_name, :family_name, :user_name, :address], :model=>:people)


  def index
    redirect_to myself_people_url
  end
  
  def configurate
    @configuration = @@configuration
    if request.post?
      @configuration.attributes = params[:configuration]
      @configuration.save
    end
  end



  def folder
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


  def folder_create
    unless @current_person.student
      flash[:error] = "Vous n'avez pas accès à ce dossier"
      redirect_to :back
      return
    end
    @person = @current_person
    @person.attributes = params[:person]
    @zone_nature = ZoneNature.find(:first, :conditions=>["LOWER(name) LIKE 'club'"])
    @zones = Zone.list(["zones.nature_id=?",@zone_nature.id]) # find(:all, :select=>"co.name||' - '||district.name||' - '||zones.name AS long_name, zones.id AS zid", :joins=>" join zones as zse on (zones.parent_id=zse.id) join zones as district on (zse.parent_id=district.id) join countries AS co ON (zones.country_id=co.id)", :conditions=>["zones.nature_id=?",@zone_nature.id], :order=>"co.iso3166, district.name, zones.name").collect {|p| [ p[:long_name], p[:zid].to_i ] }||[]
    if @zones.empty?    
      flash[:warning] = 'Vous ne pouvez pas modifier votre voyage actuellement. Réessayez plus tard.'
      redirect_to myself_people_url 
      return
    end
    if request.post?
      @person.forced = true
      if @person.save
        redirect_to :action=>:folder, :id=>@person.id
        return
      end
    end
    @title = "Enregistrement du voyage"
    render_form
  end



  def folder_update
    if params[:id].blank? or (not access?(:folders) and params[:id] != session[:current_person_id].to_s)
      flash[:error] = "Vous n'avez pas accès à ce dossier"
      redirect_to :back
      return
    end
    @person = Person.find(:first, :conditions=>{:id=>params[:id]}) # session[:current_person_id]
    @zone_nature = ZoneNature.find(:first, :conditions=>["LOWER(name) LIKE 'club'"])
    @zones = Zone.list(["zones.nature_id=?",@zone_nature.id]) # find(:all, :select=>"co.name||' - '||district.name||' - '||zones.name AS long_name, zones.id AS zid", :joins=>" join zones as zse on (zones.parent_id=zse.id) join zones as district on (zse.parent_id=district.id) join countries AS co ON (zones.country_id=co.id)", :conditions=>["zones.nature_id=?",@zone_nature.id], :order=>"co.iso3166, district.name, zones.name").collect {|p| [ p[:long_name], p[:zid].to_i ] }||[]
    if @zones.empty?    
      flash[:warning] = 'Vous ne pouvez pas modifier votre voyage actuellement. Réessayez plus tard.'
      redirect_to myself_people_url 
      return
    end
    if request.post?
      @person.attributes = params[:person]
      @person.forced = true
      if @person.save
        redirect_to :action=>:folder, :id=>@person.id
      end        
    else
      @person ||= Person.new
    end
  end




  def folder_delete
    if request.post? or request.delete?
      @person = Person.find_by_id(params[:id])
      @person.update_attribute(:promotion_id, nil) unless @person.nil?
      redirect_to :action=>:folders
    end
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

  def story
    person_id = session[:current_person_id]
    person_id = params[:id] if params[:id] # and access?
    @author = Person.find_by_id(person_id)
    @reports = @author.reports
    expire_fragment(:controller=>:intra, :action=>:story, :id=>@author.id)
  end

  def period
    @person = Person.find_by_id(session[:current_person_id])
    if params[:id]
      @period = Period.find_by_person_id_and_id(@current_person.id, params[:id])
      unless @period
        redirect_to :action=>:folder, :id=>@person.id 
        return
      end
      @title = 'Modification de la période '+@period.name
    else
      @period = Period.new(:country_id=>@person.arrival_country_id)
      @title = 'Création d\'une période et famille '
    end
    if request.post?
      @period.attributes = params[:period]
      @period.person_id = session[:current_person_id]
      if @period.save
        redirect_to :action=>:folder, :id=>@person.id
      end
    end
  end

  def period_display
    @person = Person.find_by_id(session[:current_folder_id])
    if request.xhr?
      @period = Period.find_by_id_and_person_id(params[:id], @person.id)
      @owner_mode = (session[:current_person_id]==@person.id ? true : false)
      if @period
        key = @period.id.to_s
        session[:periods][key] = false if session[:periods][key].nil?
        session[:periods][key] = !session[:periods][key]
      end
      render :partial=>'period_display', :locals=>{:owner_mode=>@owner_mode}
    else
      redirect_to :action=>:folder, :id=>@person.id
    end
  end

  def period_delete
    if request.post? or request.delete?
      @person = Person.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
      period = Period.find_by_id_and_person_id(params[:id], session[:current_person_id])
      period.destroy unless period.nil?
      redirect_to :action=>:folder, :id=>@person.id
    end
  end

  def period_add_member
    @period = Period.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if @period.nil?
      redirect_to :action=>:folder, :id=>session[:current_folder_id]
      return
    end
    @members = @current_person.members.find(:all, :order=>"last_name, first_name")||[]
    if request.post?
      @person = Person.find_by_id(session[:current_person_id])
      if params[:member][:id].nil?
        @member = Member.new(params[:member])
        @member.person_id = session[:current_person_id]
        if @member.save
          @period.members<< @member
          redirect_to :action=>:folder, :id=>@person.id
        end
      else
        @member = Member.find_by_id_and_person_id(params[:member][:id], session[:current_person_id])
        @period.members<< @member unless @period.members.exists? :id=>@member.id
        redirect_to :action=>:folder, :id=>@person.id
      end
    else
      @member = Member.new
    end
  end

  def period_remove_member
    @person = Person.find_by_id(session[:current_person_id])
    @period = Period.find_by_id_and_person_id(params[:period], session[:current_person_id])
    if @period.nil?
      redirect_to :action=>:folder, :id=>@person.id 
      return
    end
    @member = Member.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if @member.nil?
      redirect_to :action=>:folder, :id=>@person.id 
      return
    end
    if request.post?
      @period.members.delete @member
    end
    redirect_to :action=>:folder, :id=>@person.id
  end




  def member
    @person = Person.find(:first, :conditions=>{:person_id=>session[:current_person_id]})
    if params[:id]
      @member = Member.find_by_person_id_and_id(@current_person.id, params[:id])
      unless @member
        redirect_to :action=>:folder, :id=>@person.id 
        return
      end
      @title = 'Modification de '+@member.name
    else
      @member = Member.new()
      @title = 'Création d\'un membre '
    end
    if request.post?
      @member.attributes = params[:member]
      @member.person_id = session[:current_person_id]
      if @member.save
        redirect_to :action=>:folder, :id=>@person.id
      end
    end
  end



  hide_action :redirect_to_back
  def redirect_to_back()
    # if session[:history][1]
    #   session[:history].delete_at(0)
    #   redirect_to session[:history][0]
    # else
    redirect_to :back
    # end
  end
  
  # def pick_image
  #   # @images = (access? ? Image.all : @current_person.images)
  #   @images = Image.all
  #   render :partial=>'pick_image'
  # end


  def reports
    # expires_in 6.hours
    expires_now
    @countries = Country.find(:all, :select=>'distinct countries.*', :joins=>'JOIN people ON (countries.id=arrival_country_id)', :order=>:name)
    @zone_nature = ZoneNature.find(:first, :conditions=>["LOWER(name) LIKE 'zone se'"])
    @zones = Zone.find(:all, :joins=>"join countries AS co ON (zones.country_id=co.id)", :conditions=>["zones.nature_id=? AND LOWER(co.iso3166) LIKE 'fr'",@zone_nature.id], :order=>"number").collect {|p| [ p[:name], p[:id].to_i ] }||[]
    @zones.insert(0, ["-- Surligner les students d'une zone --",""])
    @zone = Zone.find_by_id(params[:id].to_i)
  end

#   def subscribers
#     # >> :subscribing
#     @title = "Liste des adhérents actuels"
#     @people = Person.paginate(:all, :joins=>"JOIN subscriptions ON (people.id=person_id)", :conditions=>["CURRENT_DATE BETWEEN begun_on AND finished_on"], :order=>:family_name, :page=>params[:page], :per_page=>50)
#     render :action=>:people
#   end

#   def non_subscribers
#     # >> :subscribing
#     @title = "Liste des non-adhérents actuels"
#     @people = Person.paginate(:all, :conditions=>"id NOT IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE BETWEEN begun_on AND finished_on)", :order=>:family_name, :page=>params[:page], :per_page=>50)
#     render :action=>:people
#   end

#   def new_non_subscribers
#     # >> :subscribing
#     @title = "Liste des futurs non-adhérents (à 2 mois)"
#     @people = Person.paginate(:all, :conditions=>"id NOT IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE+'2 months'::INTERVAL BETWEEN begun_on AND finished_on) AND id IN (SELECT person_id FROM subscriptions WHERE CURRENT_DATE BETWEEN begun_on AND finished_on)", :order=>:family_name, :page=>params[:page], :per_page=>50)
#     render :action=>:people
#   end



  def access_denied
  end



  
end
