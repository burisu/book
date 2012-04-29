# encoding: UTF-8
class ThemesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all themes
  list(:conditions => light_search_conditions(:themes => [:name, :color, :comment])) do |t|
    t.column :name, :url => true
    t.column :color
    t.column :comment
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all questions of one theme
  list(:questions, :conditions => ['theme_id = ?', ['session[:current_theme_id]']]) do |t|
    t.column :name, :url => true
    t.column :intro
    t.column :comment
    t.column :started_on
    t.column :stopped_on
    t.column :name, :through => :promotion, :url => true
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @theme = Theme.find(params[:id])
    session[:current_theme_id] = @theme.id
  end
  
  def new
    @theme = Theme.new()
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @theme }
      format.xml  { render :xml => @theme }
    end
  end
  
  def create
    @theme = Theme.new(params[:theme])
    respond_to do |format|
      if @theme.save
        format.html { redirect_to (params[:redirect] || @theme) }
        format.json { render json => @theme, :status => :created, :location => @theme }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @theme.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @theme = Theme.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @theme = Theme.find(params[:id])
    respond_to do |format|
      if @theme.update_attributes(params[:theme])
        format.html { redirect_to (params[:redirect] || @theme) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @theme.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @theme = Theme.find(params[:id])
    @theme.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || themes_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
