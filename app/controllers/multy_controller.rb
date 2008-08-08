class MultyController < ApplicationController


  def index
    home
    render :action=> :home
  end

  def home
    language=Language.find_by_iso639('FR')
    nature=ArticleNature.find_by_code('HOME')
    @articles = Article.find(:all, :conditions=>{:language_id=>language.id, :nature_id=>nature.id}, :order=>"created_at DESC")
    @events   = Event.find(:all, :order=>"done_on", :conditions=>"done_on>=CURRENT_DATE")
  end

  def new_folder
    authorize
  end
  
  def contact
  end

  def about_us
  end

  def legals
  end
end
