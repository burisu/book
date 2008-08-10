class InterController < ApplicationController


  def index
    home
    render :action=>:home
  end
  
  def home
    language=Language.find_by_iso639('FR')
    nature=ArticleNature.find_by_code('HOME')
    @articles = Article.find(:all, :conditions=>["language_id=? AND natures ILIKE '% home %'",language.id], :order=>"created_at DESC")
    @agenda   = Article.find(:all, :conditions=>["language_id=? AND natures ILIKE '% agenda %'",language.id], :order=>"done_on DESC")
  end
  
  def contact
  end

  def about_us
  end

  def legals
  end
end
