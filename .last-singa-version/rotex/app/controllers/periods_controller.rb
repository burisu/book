# -*- coding: utf-8 -*-
class PeriodsController < ApplicationController



  # def period_display()
  #   @person = Person.find_by_id(session[:current_folder_id])
  #   if request.xhr?
  #     @period = Period.find_by_id_and_person_id(params[:id], @person.id)
  #     @owner_mode = (session[:current_person_id]==@person.id ? true : false)
  #     if @period
  #       key = @period.id.to_s
  #       session[:periods][key] = false if session[:periods][key].nil?
  #       session[:periods][key] = !session[:periods][key]
  #     end
  #     render :partial=>'period_display', :locals=>{:owner_mode=>@owner_mode}
  #   else
  #     redirect_to folder_url(@person)
  #   end
  # end

  def show
    @person = Person.find_by_id(params[:folder_id])
    @period = Period.find_by_person_id_and_id(@person.id, params[:id])
    if request.xhr?
      @owner_mode = (session[:current_person_id]==@person.id ? true : false)
      if @period
        key = @period.id.to_s
        session[:periods][key] = false if session[:periods][key].nil?
        session[:periods][key] = !session[:periods][key]
      end
      render :partial=>"period", :locals=>{:owner_mode=>@owner_mode}
    end
    # if params[:id]
    #   @period = Period.find_by_person_id_and_id(@current_person.id, params[:id])
    #   unless @period
    #     redirect_to folder_url(@person) 
    #     return
    #   end
    #   @title = 'Modification de la période '+@period.name
    # else
    #   @period = Period.new(:country_id=>@person.arrival_country_id)
    #   @title = 'Création d\'une période et famille '
    # end
    # if request.post?
    #   @period.attributes = params[:period]
    #   @period.person_id = session[:current_person_id]
    #   if @period.save
    #     redirect_to folder_url(@person)
    #   end
    # end
  end

  def new
    @period = Period.new(:person_id=>params[:folder_id])
    @title = "Nouvelle famille"
    render_form
  end

  def create
    @period = Period.new(params[:period])
    @period.person_id = Person.find(params[:folder_id]).id
    if @period.save
      redirect_to folder_url(@period.person)
    end
    @title = "Nouvelle famille"
    render_form
  end

  def edit
    @period = Period.find_by_person_id_and_id(params[:folder_id], params[:id])
    @title = "Modifier la famille #{@period.name}"
    render_form
  end

  def update
    @period = Period.find_by_person_id_and_id(params[:folder_id], params[:id])
    @title = "Modifier la famille #{@period.name}"
    if @period.update_attributes(params[:period])
      redirect_to folder_url(@period.person)
    end
    render_form
  end
  

  def destroy
    @person = Person.find(params[:folder_id])
    period = Period.find_by_id_and_person_id(params[:id], @person.id)
    period.destroy unless period.nil?
    redirect_to folder_url(@person)
  end


  def memberize
    @title = "Nouveau membre..."
    @person = Person.find_by_id(params[:folder_id])
    unless @period = Period.find_by_id_and_person_id(params[:id], @person.id)
      redirect_to folder_url(@person)
      return
    end
    if request.post?
      member = Member.find_by_id_and_person_id(params[:member], @person.id)
      @period.members << member unless @period.members.exists? :id=>member.id
      redirect_to folder_url(@person)
    end
  end

  def unmemberize
    @person = Person.find_by_id(params[:folder_id])
    unless period = Period.find_by_id_and_person_id(params[:id], @person.id)
      redirect_to folder_url(@person) 
      return
    end
    unless member = Member.find_by_id_and_person_id(params[:member_id], @person.id)
      redirect_to folder_url(@person) 
      return
    end
    period.members.delete member
    redirect_to folder_url(@person)
  end

end
