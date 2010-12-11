class HomeController < ApplicationController

  def index
    language  = Language.find_by_iso639('FR')
    @articles = Article.paginate(:all, :conditions=>["language_id=? AND rubric_id=? AND status='P'", language.id, conf.home_rubric_id], :order=>"created_at DESC", :page=>params[:page], :per_page=>1)||[]
    @agenda   = Article.find(:all,     :conditions=>["language_id=? AND rubric_id=? AND done_on>=CURRENT_DATE-'2 months'::INTERVAL AND status='P'",language.id, conf.agenda_rubric_id], :order=>"done_on DESC")||[]
    @blog = []
    blog = Article.find(:all, :conditions=>["language_id=? AND rubric_id=? AND status='P'", language.id, conf.news_rubric_id])
    max = blog.size<3 ? blog.size : 3
    while @blog.size<max
      a = blog.rand
      @blog << a unless @blog.include? a 
    end    
  end
  
  def special
    if ["contact", "about", "legals", "help"].include?(params[:id])
      @article = Article.find_by_id(conf.send(params[:id]+"_article_id"))
      if @article.nil?
        flash[:warning] = "La page que vous demandez est en construction."
        redirect_to :action=>:index
      end
    else
      flash[:error] = "La page que vous demandez n'existe pas"
      redirect_to :action=>:index
    end
  end
  
  def article
    @article = Article.find(params[:id])
    if @article.nil?
      flash[:error] = "La page que vous demandez n'existe pas"
      redirect_to :action=>:index
    end
    if @current_person.nil? and not @article.public?
      flash[:error] = "Veuillez vous connecter pour accéder à l'article."
      redirect_to :controller=>:authentication, :action=>:login
    elsif @current_person
      unless @article.author_id == @current_person.id or access? :publishing or @article.published?
        @article = nil
        flash[:error] = "Vous n'avez pas le droit d'accéder à cet article."
        redirect_to :back
      end
    end
  end

end
