class LanguagesController < ApplicationController
  before_filter :authorize

  def index
  end

  def new
    @language = Language.new
    @title = "Nouvelle langue"
    render_form
  end

  def create
    @language = Language.new(params[:language])
    if @language.save
      redirect_to languages_url
    end
    @title = "Nouvelle langue"
    render_form
  end

  def edit
    @language = Language.find_by_iso639(params[:id])
    @title = "Modifier la langue #{@language.name}"
    render_form
  end

  def update
    @language = Language.find_by_iso639(params[:id])
    @title = "Modifier la langue #{@language.name}"
    if @language.update_attributes(params[:language])
      redirect_to languages_url
    end
    render_form
  end

  def destroy
    Language.find_by_iso639(params[:id]).destroy
    redirect_to languages_url
  end

end
