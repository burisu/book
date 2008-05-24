class MultyController < ApplicationController


  def index
    home
    render :action=> :home
  end

  def home
    language=Language.find_by_iso639('FR')
    nature=ArticleNature.find_by_code('HOME')
    @article=Article.find_by_language_id_and_nature_id(language.id,nature.id)
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
