class InterController < ApplicationController

  def index
    home
    render :action=>:home
  end
  
  def home
    language  = Language.find_by_iso639('FR')
    @articles = Article.paginate(:all, :conditions=>["language_id=? AND natures ILIKE '% home %'",language.id], :order=>"created_at DESC", :page=>params[:page], :per_page=>5)||[]
    @agenda   = Article.find(:all, :conditions=>["language_id=? AND natures ILIKE '% agenda %' AND done_on>=CURRENT_DATE-'2 months'::INTERVAL",language.id], :order=>"done_on DESC")||[]
  end
  
  def special
    if ["contact","about_us","legals"].include?(params[:id])
      @article = Article.find(:first, :conditions=>["natures ILIKE '% '||?||' %'",params[:id]])
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
