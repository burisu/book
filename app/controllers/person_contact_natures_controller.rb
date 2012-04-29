# encoding: UTF-8
class PersonContactNaturesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all person_contact_natures
  list(:conditions => light_search_conditions(:person_contact_natures => [:name, :canal])) do |t|
    t.column :name, :url => true
    t.column :canal
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  # List all person_contacts of one person_contact_nature
  list(:person_contacts, :conditions => ['person_contact_nature_id = ?', ['session[:current_person_contact_nature_id]']]) do |t|
    t.column :label, :through => :person, :url => true
    t.column :name, :through => :nature, :url => true
    t.column :canal
    t.column :address
    t.column :line_2
    t.column :line_3
    t.column :line_4
    t.column :line_5
    t.column :line_6
    t.column :postcode
    t.column :city
    t.column :country
    t.column :receiving
    t.column :sending
    t.column :by_default
    t.action :edit, :url=>{:redirect => 'request.url'}
    t.action :destroy, :method => :delete, :confirm => :are_you_sure, :url=>{:redirect => 'request.url'}
  end
  
  def show
    @person_contact_nature = PersonContactNature.find(params[:id])
    session[:current_person_contact_nature_id] = @person_contact_nature.id
  end
  
  def new
    @person_contact_nature = PersonContactNature.new()
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @person_contact_nature }
      format.xml  { render :xml => @person_contact_nature }
    end
  end
  
  def create
    @person_contact_nature = PersonContactNature.new(params[:person_contact_nature])
    respond_to do |format|
      if @person_contact_nature.save
        format.html { redirect_to (params[:redirect] || @person_contact_nature) }
        format.json { render json => @person_contact_nature, :status => :created, :location => @person_contact_nature }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @person_contact_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @person_contact_nature = PersonContactNature.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @person_contact_nature = PersonContactNature.find(params[:id])
    respond_to do |format|
      if @person_contact_nature.update_attributes(params[:person_contact_nature])
        format.html { redirect_to (params[:redirect] || @person_contact_nature) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @person_contact_nature.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @person_contact_nature = PersonContactNature.find(params[:id])
    @person_contact_nature.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || person_contact_natures_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
