# encoding: UTF-8
class OrganigramsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all organigrams
  list(:conditions => light_search_conditions(:organigrams => [:name, :code, :description])) do |t|
    t.column :name, :url => true
    t.column :code
    t.column :description
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all professions of one organigram
  list(:professions, :model => 'OrganigramProfession', :conditions => ['organigram_id = ?', ['session[:current_organigram_id]']]) do |t|
    t.column :name, :url => true
    t.column :code
    t.column :printed
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @organigram = Organigram.find(params[:id])
    session[:current_organigram_id] = @organigram.id
  end
  
  def new
    @organigram = Organigram.new()
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @organigram }
      format.xml  { render :xml => @organigram }
    end
  end
  
  def create
    @organigram = Organigram.new(params[:organigram])
    respond_to do |format|
      if @organigram.save
        format.html { redirect_to (params[:redirect] || @organigram) }
        format.json { render json => @organigram, :status => :created, :location => @organigram }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @organigram.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @organigram = Organigram.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @organigram = Organigram.find(params[:id])
    respond_to do |format|
      if @organigram.update_attributes(params[:organigram])
        format.html { redirect_to (params[:redirect] || @organigram) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @organigram.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @organigram = Organigram.find(params[:id])
    @organigram.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || organigrams_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
