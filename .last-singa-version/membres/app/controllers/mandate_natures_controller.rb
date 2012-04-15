class MandateNaturesController < ApplicationController

  def index
  end

  def new
    @mandate_nature = MandateNature.new
    @title = "Nouveau type de mandat"
    render_form
  end

  def create
    @mandate_nature = MandateNature.new(params[:mandate_nature])
    if @mandate_nature.save
      redirect_to mandate_natures_url
    end
    @title = "Nouveau type de mandat"
    render_form
  end

  def edit
    @mandate_nature = MandateNature.find_by_code(params[:id])
    @title = "Modifier le type de mandat #{@mandate_nature.name}"
    render_form
  end

  def update
    @mandate_nature = MandateNature.find_by_code(params[:id])
    @title = "Modifier le type de mandat #{@mandate_nature.name}"
    if @mandate_nature.update_attributes(params[:mandate_nature])
      redirect_to mandate_natures_url
    end
    render_form
  end

  def destroy
    MandateNature.find_by_code(params[:id]).destroy
    redirect_to mandate_natures_url
  end

end
