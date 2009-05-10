class HomeController < ApplicationController

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
      @article = Article.find(:first, :conditions=>["natures ILIKE '% '||?||' %' AND status='P'",params[:id]])
      if @article.nil?
        flash[:warning] = "La page que vous demandez est en construction."
        redirect_to :action=>:home
      end
    else
      flash[:error] = "La page que vous demandez n'existe pas"
      redirect_to :action=>:home
    end
  end
  
  def article
    @article = Article.find params[:id]
    if @article.nil?
      flash[:error] = "La page que vous demandez n'existe pas"
      redirect_to :action=>:home
    end
    if @article.natures_include?(:blog) and @current_user.nil?
      flash[:error] = "La page que vous demandez n'existe pas"
      redirect_to :action=>:home
    end
  end

end
