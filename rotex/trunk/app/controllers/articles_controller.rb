class ArticlesController < ApplicationController

  # :conditions=>{:status=>['session[:articles_status]']}, 
  dyta(:articles, :joins=>"JOIN people ON (people.id=author_id)", :order=>"people.family_name, people.first_name, created_at DESC", :per_page=>20, :line_class=>"(RECORD.status.to_s == 'R' ? 'warning' : (Time.now-RECORD.updated_at <= 3600*24*30 ? 'notice' : ''))") do |t|
    t.column :title, :url=>{:action=>:show}
    t.column :name, :through=>:rubric, :url=>{:controller=>:rubrics, :action=>:show}
    t.column :label, :through=>:author, :url=>{:controller=>:people, :action=>:show}
    t.column :updated_at
    t.action :status, :actions=>{"P"=>{:action=>:deactivate}, "R"=>{:action=>:activate}, "U"=>{:action=>:activate}, "W"=>{:action=>:edit}, "C"=>{:action=>:edit}}
    t.action :destroy, :method=>:delete, :confirm=>"Sûr(e)\?"
  end


  def index
    @title = "Tous les articles"
  end


  # copie de Home#article
  def show
    @article = Article.find(params[:id])
    if @article.nil?
      flash[:error] = "La page que vous demandez n'existe pas"
      redirect_to :action=>:index
    end
    if @current_person.nil? and not @article.public?
      flash[:error] = "Veuillez vous connecter pour accéder à l'article."
      redirect_to :controller=>:authentication, :action=>:login
    elsif @current_person
      # @article.published?
      unless @article.author_id == @current_person.id or @article.can_be_read_by?(@current_person) or access? :publishing
        @article = nil
        flash[:error] = "Vous n'avez pas le droit d'accéder à cet article."
        redirect_to :back
      end
    end
  end


  def new
    @article = Article.new(:rubric_id=>params[:rubric_id])
    @article.done_on = session[:report_done_on] if session[:report_done_on]
    render_form
  end


  def create
    @article = Article.new
    # params[:article][:done_on] = session[:report_done_on] if session[:report_done_on].is_a? Date and !access?(:publishing)
    @article.preload(params[:article], @current_person)
    @article.done_on = session[:report_done_on] if session[:report_done_on].is_a? Date and !access?(:publishing)
    # @article.natures = 'default' unless access? :publishing
    if @article.save
      # Mandate Nature à implémenter
      @article.mandate_natures.clear
      for k,v in params[:mandate_natures]||[]
        @article.mandate_natures << MandateNature.find(k) if v.to_s == "1"
      end
      redirect_to myself_people_url
    end
    render_form
  end


  def edit
    @article = Article.find(params[:id])
    redirect_to :action=>:access_denied unless @article.author_id==@current_person.id or access? :publishing
    @article.to_correct if @article.ready?
    if @article.locked? and !access? :publishing
      flash[:warning] = "L'article a été validé par le rédacteur en chef et ne peut plus être modifié. Merci de votre compréhension."
      redirect_to :back
      return
    end
    render_form
  end


  def update
    @article = Article.find(params[:id])
    redirect_to :action=>:access_denied unless @article.author_id==@current_person.id or access? :publishing
    if @article.locked? and !access? :publishing
      flash[:warning] = "L'article a été validé par le rédacteur en chef et ne peut plus être modifié. Merci de votre compréhension."
      redirect_to :back
      return
    end
    @article.preload(params[:article], @current_person)
    if @article.save
      # Mandate Nature à implémenter
      @article.mandate_natures.clear
      for k,v in params[:mandate_natures]||[]
        @article.mandate_natures << MandateNature.find(k) if v.to_s == "1"
      end
      expire_fragment({:controller=>:home, :action=>:article_complete, :id=>@article.id})
      expire_fragment({:controller=>:home, :action=>:article_extract, :id=>@article.id})
      flash[:notice] = 'Vos modifications ont été enregistrées ('+I18n.localize(Time.now)+')'
      if params[:save_and_exit]
        redirect_to_back
      else
        redirect_to :back
      end
    end
    render_form
  end



  def destroy
    if request.post? or request.delete?
      @article = Article.find(params[:id])
      if @article.nil?
        flash[:error] = "La page que vous demandez n'existe pas"
      else
        Article.destroy(@article)
        flash[:notice] = "Article supprimé"
      end
    end
    redirect_to :back
  end



  def preview
    @textile = params[:textile]||''
    @current_user = nil
    render :partial=>'preview' if request.xhr?
  end



  def publish
    @article = Article.find(params[:id])
    if @article.author_id==@current_person.id or access? :publishing
      @article.to_publish
      redirect_to :back
    else
      redirect_to :action=>:access_denied 
    end
  end



  def activate
    Article.find(params[:id]).publish
    redirect_to :back
  end


  def deactivate
    Article.find(params[:id]).unpublish
    redirect_to :back
  end

end
