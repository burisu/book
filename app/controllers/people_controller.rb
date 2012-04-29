# encoding: UTF-8
class PeopleController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all people
  list(:conditions => light_search_conditions(:people => [:patronymic_name, :family_name, :first_name, :second_name, :user_name, :photo_file_name, :sex, :born_on, :email, :rotex_email, :student, :comment, :promotion_id, :language, :birth_country, :photo_file_size, :photo_content_type, :photo_updated_at, :activity_id, :profession_id])) do |t|
    t.column :patronymic_name
    t.column :family_name
    t.column :first_name
    t.column :second_name
    t.column :user_name
    t.column :photo_file_name
    t.column :sex
    t.column :born_on
    t.column :email
    t.column :rotex_email
    t.column :student
    t.column :comment
    t.column :name, :through => :promotion, :url => true
    t.column :language
    t.column :birth_country
    t.column :photo_file_size
    t.column :photo_content_type
    t.column :photo_updated_at
    t.column :label, :through => :activity, :url => true
    t.column :name, :through => :profession, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all answers of one person
  list(:answers, :conditions => ['person_id = ?', ['session[:current_person_id]']]) do |t|
    t.column :created_on
    t.column :ready
    t.column :locked
    t.column :name, :through => :question, :url => true
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  # List all articles of one person
  list(:articles, :conditions => ['author_id = ?', ['session[:current_person_id]']]) do |t|
    t.column :title
    t.column :intro
    t.column :body
    t.column :done_on
    t.column :bad_natures
    t.column :status
    t.column :document
    t.column :name, :through => :rubric, :url => true
    t.column :language
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  # List all images of one person
  list(:images, :conditions => ['person_id = ?', ['session[:current_person_id]']]) do |t|
    t.column :title
    t.column :title_h
    t.column :desc
    t.column :desc_h
    t.column :document_file_name
    t.column :name, :url => true
    t.column :locked
    t.column :deleted
    t.column :published
    t.column :document_file_size
    t.column :document_content_type
    t.column :document_updated_at
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  # List all members of one person
  list(:members, :conditions => ['person_id = ?', ['session[:current_person_id]']]) do |t|
    t.column :last_name
    t.column :first_name
    t.column :photo
    t.column :nature
    t.column :other_nature
    t.column :sex
    t.column :phone
    t.column :fax
    t.column :mobile
    t.column :comment
    t.column :email
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  # List all periods of one person
  list(:periods, :conditions => ['person_id = ?', ['session[:current_person_id]']]) do |t|
    t.column :begun_on
    t.column :finished_on
    t.column :comment
    t.column :family_name
    t.column :address
    t.column :latitude
    t.column :longitude
    t.column :photo
    t.column :phone
    t.column :fax
    t.column :email
    t.column :mobile
    t.column :country
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  # List all sales of one person
  list(:sales, :conditions => ['client_id = ?', ['session[:current_person_id]']]) do |t|
    t.column :number, :url => true
    t.column :comment
    t.column :client_email
    t.column :amount
    t.column :payment_mode
    t.column :payment_number
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  # List all subscriptions of one person
  list(:subscriptions, :conditions => ['person_id = ?', ['session[:current_person_id]']]) do |t|
    t.column :begun_on
    t.column :finished_on
    t.column :number, :url => true
    t.column :number, :through => :sale, :url => true
    t.column :name, :through => :sale_line, :url => true
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  # List all mandates of one person
  list(:mandates, :conditions => ['person_id = ?', ['session[:current_person_id]']]) do |t|
    t.column :dont_expire
    t.column :started_on
    t.column :stopped_on
    t.column :name, :through => :nature, :url => true
    t.column :name, :through => :group, :url => true
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @person = Person.find(params[:id])
    session[:current_person_id] = @person.id
  end
  
  def new
    @person = Person.new(:activity_id => params[:activity_id].to_i, :arrival_person_id => params[:arrival_person_id].to_i, :departure_person_id => params[:departure_person_id].to_i, :host_zone_id => params[:host_zone_id].to_i, :profession_id => params[:profession_id].to_i, :promotion_id => params[:promotion_id].to_i, :proposer_zone_id => params[:proposer_zone_id].to_i, :sponsor_zone_id => params[:sponsor_zone_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @person }
      format.xml  { render :xml => @person }
    end
  end
  
  def create
    @person = Person.new(params[:person])
    respond_to do |format|
      if @person.save
        format.html { redirect_to (params[:redirect] || @person) }
        format.json { render json => @person, :status => :created, :location => @person }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @person = Person.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @person = Person.find(params[:id])
    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to (params[:redirect] || @person) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @person = Person.find(params[:id])
    @person.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || people_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
