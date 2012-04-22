# encoding: UTF-8
class OrganigramProfessionsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all organigram_professions
  list :conditions => light_search_conditions(:organigram_professions => [:organigram_id, :name, :printed]) do |t|
    t.column :name, :through => :organigram, :url => true
    t.column :name, :url => true
    t.column :printed
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @organigram_profession = OrganigramProfession.find(params[:id])
    session[:current_organigram_profession_id] = @organigram_profession.id
  end
  
  def new
    @organigram_profession = OrganigramProfession.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @organigram_profession }
      format.xml  { render :xml => @organigram_profession }
    end
  end
  
  def create
    @organigram_profession = OrganigramProfession.new(params[:organigram_profession])
    respond_to do |format|
      if @organigram_profession.save
        format.html { redirect_to @organigram_profession }
        format.json { render json => @organigram_profession, :status => :created, :location => @organigram_profession }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @organigram_profession.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @organigram_profession = OrganigramProfession.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @organigram_profession = OrganigramProfession.find(params[:id])
    respond_to do |format|
      if @organigram_profession.update_attributes(params[:organigram_profession])
        format.html { redirect_to @organigram_profession }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @organigram_profession.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @organigram_profession = OrganigramProfession.find(params[:id])
    @organigram_profession.destroy
    respond_to do |format|
      format.html { redirect_to organigram_professions_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
