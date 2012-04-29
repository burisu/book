# encoding: UTF-8
class ArticlesController < ApplicationController
  #[ACTIONS[ Do not edit these lines directly.
  # List all articles
  list(:conditions => light_search_conditions(:articles => [:title, :intro, :body, :done_on, :bad_natures, :status, :document, :author_id, :rubric_id, :language])) do |t|
    t.column :title
    t.column :intro
    t.column :body
    t.column :done_on
    t.column :bad_natures
    t.column :status
    t.column :document
    t.column :label, :through => :author, :url => true
    t.column :name, :through => :rubric, :url => true
    t.column :language
    t.action :edit
    t.action :destroy, :method => :delete, :confirm => :are_you_sure
  end
  
  def index
  end
  
  def show
    @article = Article.find(params[:id])
    session[:current_article_id] = @article.id
  end
  
  def new
    @article = Article.new(:author_id => params[:author_id].to_i, :rubric_id => params[:rubric_id].to_i)
    respond_to do |format|
      format.html { render_restfully_form}
      format.json { render :json => @article }
      format.xml  { render :xml => @article }
    end
  end
  
  def create
    @article = Article.new(params[:article])
    respond_to do |format|
      if @article.save
        format.html { redirect_to (params[:redirect] || @article) }
        format.json { render json => @article, :status => :created, :location => @article }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @article.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @article = Article.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @article = Article.find(params[:id])
    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to (params[:redirect] || @article) }
        format.json { head :no_content }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @article.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || articles_url) }
      format.json { head :no_content }
    end
  end
  #]ACTIONS]


end
