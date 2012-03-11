class ZoneNaturesController < ApplicationController

  def index
  end

  def new
    @zone_nature = ZoneNature.new(:parent_id=>params[:parent_id])
    @title = "Nouveau type de zone"
    render_form
  end

  def create
    @zone_nature = ZoneNature.new(params[:zone_nature])
    if @zone_nature.save
      redirect_to zone_natures_url
    end
    @title = "Nouveau type de zone"
    render_form
  end

  def edit
    @zone_nature = ZoneNature.find_by_code(params[:id])
    @title = "Modifier le type de zone #{@zone_nature.name}"
    render_form
  end

  def update
    @zone_nature = ZoneNature.find_by_code(params[:id])
    @title = "Modifier le type de zone #{@zone_nature.name}"
    if @zone_nature.update_attributes(params[:zone_nature])
      redirect_to zone_natures_url
    end
    render_form
  end

  def destroy
    ZoneNature.find_by_code(params[:id]).destroy
    redirect_to zone_natures_url
  end

end
