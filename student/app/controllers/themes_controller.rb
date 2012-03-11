class ThemesController < ApplicationController

  dyta(:themes, :order=>:name) do |t|
    t.column :name
    t.column :color
    t.column :comment
    t.action :edit
    t.action :destroy, :method=>:delete, :confirm=>"Are you sure\?"
  end

  def index
  end

  def new
    @theme = Theme.new
    @title = "Nouveau thème"
    render_form
  end

  def create
    @theme = Theme.new(params[:theme])
    if @theme.save
      redirect_to themes_url
    end
    @title = "Nouveau thème"
    render_form
  end

  def edit
    @theme = Theme.find(params[:id])
    @title = "Modifier le thème #{@theme.name}"
    render_form
  end

  def update
    @theme = Theme.find(params[:id])
    @title = "Modifier le thème #{@theme.name}"
    if @theme.update_attributes(params[:theme])
      redirect_to themes_url
    end
    render_form
  end

  def destroy
    Theme.find(params[:id]).destroy
    redirect_to themes_url
  end

end
