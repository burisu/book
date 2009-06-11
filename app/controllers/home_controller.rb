class HomeController < ApplicationController

  before_filter :vision
  def vision
    redirect_to :controller=>:suivi unless @vision==:rotex
  end

  def index
    language  = Language.find_by_iso639('FR')
    @articles = Article.paginate(:all, :conditions=>["language_id=? AND natures ILIKE '% home %' AND status='P'",language.id], :order=>"created_at DESC", :page=>params[:page], :per_page=>5)||[]
    @agenda   = Article.find(:all, :conditions=>["language_id=? AND natures ILIKE '% agenda %' AND done_on>=CURRENT_DATE-'2 months'::INTERVAL AND status='P'",language.id], :order=>"done_on DESC")||[]
    @blog = []
    blog = Article.find(:all, :conditions=>["language_id=? AND natures ILIKE '% blog %' AND status='P'",language.id])
    max = blog.size<3 ? blog.size : 3
    while @blog.size<max
      a = blog.rand
      @blog << a unless @blog.include? a 
    end    
  end
  
  def special
    if ["contact","about_us","legals"].include?(params[:id])
      @article = Article.find(:first, :conditions=>["natures LIKE ? AND status=?",'%'+params[:id].to_s+'%', 'P'])
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
    if @current_person.nil? and not @article.natures_include?(:home) and not @article.natures_include?(:agenda) and not @article.natures_include?(:about_us) and not @article.natures_include?(:contact) and not @article.natures_include?(:legals)
      flash[:error] = "Veuillez vous connecter pour accéder à l'article."
      redirect_to :controller=>:auth, :action=>:login
    elsif @current_person
      unless @article.author_id = @current_person.id or access? :publishing
        @article = nil
        flash[:error] = "Vous n'avez pas le droit d'accéder à cet article."
        redirect_to :back
      end
    end
  end

end
