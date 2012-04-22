# encoding: UTF-8
class ImagesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all images
  list :conditions => light_search_conditions(:images => [:title, :title_h, :desc, :desc_h, :document_file_name, :person_id, :name, :locked, :deleted, :published, :document_file_size, :document_content_type, :document_updated_at]) do |t|
    t.column :title
    t.column :title_h
    t.column :desc
    t.column :desc_h
    t.column :document_file_name
    t.column :label, :through => :person, :url => true
    t.column :name, :url => true
    t.column :locked
    t.column :deleted
    t.column :published
    t.column :document_file_size
    t.column :document_content_type
    t.column :document_updated_at
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @image = Image.find(params[:id])
    session[:current_image_id] = @image.id
  end
  
  def new
    @image = Image.new
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @image }
      format.xml  { render :xml => @image }
    end
  end
  
  def create
    @image = Image.new(params[:image])
    respond_to do |format|
      if @image.save
        format.html { redirect_to @image }
        format.json { render json => @image, :status => :created, :location => @image }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @image = Image.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @image = Image.find(params[:id])
    respond_to do |format|
      if @image.update_attributes(params[:image])
        format.html { redirect_to @image }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
