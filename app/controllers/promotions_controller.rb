# encoding: UTF-8
class PromotionsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all promotions
  list :conditions => light_search_conditions(:promotions => [:name, :is_outbound, :from_code]) do |t|
    t.column :name, :url => true
    t.column :is_outbound
    t.column :from_code
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all people of one promotion
  list(:people, :conditions => ['promotion_id = ?', ['session[:current_promotion_id]']]) do |t|
    t.column :patronymic_name
    t.column :family_name
    t.column :family_id # No reflection found
    t.column :first_name
    t.column :second_name
    t.column :user_name
    t.column :photo_file_name
    t.column :sex
    t.column :born_on
    t.column :latitude
    t.column :longitude
    t.column :email
    t.column :replacement_email
    t.column :hashed_password
    t.column :salt
    t.column :rotex_email
    t.column :validation
    t.column :is_validated
    t.column :is_locked
    t.column :is_user
    t.column :student
    t.column :label, :through => :arrival_person, :url => true
    t.column :started_on
    t.column :stopped_on
    t.column :comment
    t.column :label, :through => :departure_person, :url => true
    t.column :name, :through => :host_zone, :url => true
    t.column :name, :through => :proposer_zone, :url => true
    t.column :name, :through => :sponsor_zone, :url => true
    t.column :approved
    t.column :language
    t.column :birth_country
    t.column :arrival_country
    t.column :departure_country
    t.column :photo_file_size
    t.column :photo_content_type
    t.column :photo_updated_at
    t.column :activity_id # No reflection found
    t.column :profession_id # No reflection found
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  # List all questions of one promotion
  list(:questions, :conditions => ['promotion_id = ?', ['session[:current_promotion_id]']]) do |t|
    t.column :name, :url => true
    t.column :intro
    t.column :comment
    t.column :started_on
    t.column :stopped_on
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def show
    @promotion = Promotion.find(params[:id])
    session[:current_promotion_id] = @promotion.id
  end
  
  def new
    @promotion = Promotion.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @promotion }
      format.xml  { render :xml => @promotion }
    end
  end
  
  def create
    @promotion = Promotion.new(params[:promotion])
    respond_to do |format|
      if @promotion.save
        format.html { redirect_to @promotion }
        format.json { render json => @promotion, :status => :created, :location => @promotion }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @promotion.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @promotion = Promotion.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @promotion = Promotion.find(params[:id])
    respond_to do |format|
      if @promotion.update_attributes(params[:promotion])
        format.html { redirect_to @promotion }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @promotion.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @promotion = Promotion.find(params[:id])
    @promotion.destroy
    respond_to do |format|
      format.html { redirect_to promotions_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
