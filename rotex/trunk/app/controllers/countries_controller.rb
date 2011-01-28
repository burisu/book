class CountriesController < ApplicationController

  def index
  end

  def new
    @country = Country.new
    @title = "Nouveau pays"
    render_form
  end

  def create
    @country = Country.new(params[:country])
    if @country.save
      redirect_to countries_url
    end
    @title = "Nouveau pays"
    render_form
  end

  def edit
    @country = Country.find_by_iso3166(params[:id])
    @title = "Modifier le pays #{@country.name}"
    render_form
  end

  def update
    @country = Country.find_by_iso3166(params[:id])
    @title = "Modifier le pays #{@country.name}"
    if @country.update_attributes(params[:country])
      redirect_to countries_url
    end
    render_form
  end

  def destroy
    Country.find_by_iso3166(params[:id]).destroy
    redirect_to countries_url
  end

end
