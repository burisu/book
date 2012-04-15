class ImagesController < ApplicationController

  @@images_count_per_person = 100
  cattr_reader :images_count_per_person


  def index
    @images = Image.find(:all, :conditions=>{:person_id=>session[:current_person_id]}, :order=>:title)
    render :partial=>'selector', :layout=>false if request.xhr?
  end


  def show
    @image = Image.find_by_id(params[:id])
    redirect_to images_url if @image.nil?
  end

  def new
    @image = Image.new
    render_form :multipart=>:true
  end
  

  def create
    @image = Image.new(params[:image])
    @image.person_id = session[:current_person_id]
    if @image.save
      redirect_to images_url
      return
    end
    render_form :multipart=>:true
  end

  def edit
    @image = Image.find_by_id_and_person_id(params[:id], session[:current_person_id])
    render_form :multipart=>:true
  end

  def update
    @image = Image.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if @image.update_attributes(params[:image])
      redirect_to images_url 
      return
    end
    render_form :multipart=>:true
  end

  def destroy
    image = Image.find_by_id_and_person_id(params[:id], session[:current_person_id])
    if image and image.deletable?
      Image.destroy(image.id) if request.delete?
    end
    redirect_to images_url
  end

end
