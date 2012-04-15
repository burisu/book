# -*- coding: utf-8 -*-
class MembersController < ApplicationController

  def new
    @person = Person.find(params[:folder_id])
    @member = Member.new
    @title = "Nouveau membre..."
    render_form
  end

  def create
    @person = Person.find(params[:folder_id])
    @member = Member.new(params[:member])
    @title = "Nouveau membre..."
    @member.person_id = @person.id
    if @member.save
      redirect_to params[:redirect]||folder_url(@person)
    end
    render_form
  end

  def edit
    @person = Person.find(params[:folder_id])
    @member = Member.find_by_id_and_person_id(params[:id], @person.id)
    @title = "Modifier le membre..."
    render_form
  end

  def update
    @person = Person.find(params[:folder_id])
    @member = Member.find_by_id_and_person_id(params[:id], @person.id)
    @title = "Modifier le membre..."
    if @member.update_attributes(params[:member])
      redirect_to params[:redirect]||folder_url(@person)
    end
    render_form
  end

  def destroy
    @person = Person.find(params[:folder_id])
    @member = Member.find_by_id_and_person_id(params[:id], @person.id)
    @member.destroy
    redirect_to params[:redirect]||folder_url(@person)    
  end

  # def member()
  #   @person = Person.find(:first, :conditions=>{:id=>session[:current_person_id]})
  #   if params[:id]
  #     @member = Member.find_by_person_id_and_id(@current_person.id, params[:id])
  #     unless @member
  #       redirect_to :action=>:folder, :id=>@person.id 
  #       return
  #     end
  #     @title = 'Modification de '+@member.name
  #   else
  #     @member = Member.new()
  #     @title = 'Création d\'un membre '
  #   end
  #   if request.post?
  #     @member.attributes = params[:member]
  #     @member.person_id = session[:current_person_id]
  #     if @member.save
  #       redirect_to :action=>:folder, :id=>@person.id
  #     end
  #   end
  # end

end
