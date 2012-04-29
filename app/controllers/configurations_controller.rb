# encoding: UTF-8
class ConfigurationsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all configurations
  list(:conditions => light_search_conditions(:configurations => [:contact_article_id, :about_article_id, :legals_article_id, :home_rubric_id, :news_rubric_id, :agenda_rubric_id, :subscription_price, :store_introduction, :help_article_id, :chasing_up_days, :chasing_up_letter_before_expiration, :chasing_up_letter_after_expiration])) do |t|
    t.column :label, :through => :contact_article, :url => true
    t.column :label, :through => :about_article, :url => true
    t.column :label, :through => :legals_article, :url => true
    t.column :name, :through => :home_rubric, :url => true
    t.column :name, :through => :news_rubric, :url => true
    t.column :name, :through => :agenda_rubric, :url => true
    t.column :subscription_price
    t.column :store_introduction
    t.column :label, :through => :help_article, :url => true
    t.column :chasing_up_days
    t.column :chasing_up_letter_before_expiration
    t.column :chasing_up_letter_after_expiration
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @configuration = Configuration.find(params[:id])
    session[:current_configuration_id] = @configuration.id
  end
  
  def new
    @configuration = Configuration.new(:about_article_id => params[:about_article_id].to_i, :agenda_rubric_id => params[:agenda_rubric_id].to_i, :contact_article_id => params[:contact_article_id].to_i, :help_article_id => params[:help_article_id].to_i, :home_rubric_id => params[:home_rubric_id].to_i, :legals_article_id => params[:legals_article_id].to_i, :news_rubric_id => params[:news_rubric_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @configuration }
      format.xml  { render :xml => @configuration }
    end
  end
  
  def create
    @configuration = Configuration.new(params[:configuration])
    respond_to do |format|
      if @configuration.save
        format.html { redirect_to (params[:redirect] || @configuration) }
        format.json { render json => @configuration, :status => :created, :location => @configuration }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @configuration.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @configuration = Configuration.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @configuration = Configuration.find(params[:id])
    respond_to do |format|
      if @configuration.update_attributes(params[:configuration])
        format.html { redirect_to (params[:redirect] || @configuration) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @configuration.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @configuration = Configuration.find(params[:id])
    @configuration.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || configurations_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
