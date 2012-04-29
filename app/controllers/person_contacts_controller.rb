# encoding: UTF-8
class PersonContactsController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all person_contacts
  list(:conditions => light_search_conditions(:person_contacts => [:person_id, :nature_id, :canal, :address, :line_2, :line_3, :line_4, :line_5, :line_6, :postcode, :city, :country, :receiving, :sending, :by_default])) do |t|
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
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @person_contact = PersonContact.find(params[:id])
    session[:current_person_contact_id] = @person_contact.id
  end
  
  def new
    @person_contact = PersonContact.new(:nature_id => params[:nature_id].to_i, :person_id => params[:person_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @person_contact }
      format.xml  { render :xml => @person_contact }
    end
  end
  
  def create
    @person_contact = PersonContact.new(params[:person_contact])
    respond_to do |format|
      if @person_contact.save
        format.html { redirect_to (params[:redirect] || @person_contact) }
        format.json { render json => @person_contact, :status => :created, :location => @person_contact }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @person_contact.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @person_contact = PersonContact.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @person_contact = PersonContact.find(params[:id])
    respond_to do |format|
      if @person_contact.update_attributes(params[:person_contact])
        format.html { redirect_to (params[:redirect] || @person_contact) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @person_contact.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @person_contact = PersonContact.find(params[:id])
    @person_contact.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || person_contacts_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
