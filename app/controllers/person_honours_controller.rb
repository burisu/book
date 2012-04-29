# encoding: UTF-8
class PersonHonoursController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all person_honours
  list(:conditions => light_search_conditions(:person_honours => [:person_id, :honour_id, :given_on, :comment])) do |t|
    t.column :label, :through => :person, :url => true
    t.column :name, :through => :honour, :url => true
    t.column :given_on
    t.column :comment, :url => true
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @person_honour = PersonHonour.find(params[:id])
    session[:current_person_honour_id] = @person_honour.id
  end
  
  def new
    @person_honour = PersonHonour.new(:honour_id => params[:honour_id].to_i, :person_id => params[:person_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @person_honour }
      format.xml  { render :xml => @person_honour }
    end
  end
  
  def create
    @person_honour = PersonHonour.new(params[:person_honour])
    respond_to do |format|
      if @person_honour.save
        format.html { redirect_to (params[:redirect] || @person_honour) }
        format.json { render json => @person_honour, :status => :created, :location => @person_honour }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @person_honour.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @person_honour = PersonHonour.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @person_honour = PersonHonour.find(params[:id])
    respond_to do |format|
      if @person_honour.update_attributes(params[:person_honour])
        format.html { redirect_to (params[:redirect] || @person_honour) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @person_honour.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @person_honour = PersonHonour.find(params[:id])
    @person_honour.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || person_honours_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
