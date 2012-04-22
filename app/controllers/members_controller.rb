# encoding: UTF-8
class MembersController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all members
  list :conditions => light_search_conditions(:members => [:last_name, :first_name, :photo, :nature, :other_nature, :sex, :phone, :fax, :mobile, :comment, :person_id, :email]) do |t|
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
    t.column :label, :through => :person, :url => true
    t.column :email
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @member = Member.find(params[:id])
    session[:current_member_id] = @member.id
  end
  
  def new
    @member = Member.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @member }
      format.xml  { render :xml => @member }
    end
  end
  
  def create
    @member = Member.new(params[:member])
    respond_to do |format|
      if @member.save
        format.html { redirect_to @member }
        format.json { render json => @member, :status => :created, :location => @member }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @member.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @member = Member.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @member = Member.find(params[:id])
    respond_to do |format|
      if @member.update_attributes(params[:member])
        format.html { redirect_to @member }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @member.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
