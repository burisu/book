class ZonesController < ApplicationController
  
  def index
  end

  def show
    @zone = Zone.find(params[:id])
  end

  def new
    @zone = if parent = Zone.find_by_id(params[:parent_id])
              Zone.new(:parent_id=>parent.id, :country=>parent.country)
            else
              Zone.new
            end
    @title = "Nouvelle zone"
    render_form
  end

  def create
    @zone = Zone.new(params[:zone])
    if @zone.save
      redirect_to zone_url(@zone)
    end
    @title = "Nouvelle zone"
    render_form
  end

  def edit
    @zone = Zone.find(params[:id])
    @title = "Modifier la zone #{@zone.name}"
    render_form
  end

  def update
    @zone = Zone.find(params[:id])
    @title = "Modifier la zone #{@zone.name}"
    if @zone.update_attributes(params[:zone])
      redirect_to zone_url(@zone)
    end
    render_form
  end

  def destroy
    zone = Zone.find(params[:id])
    zone.destroy
    redirect_to (zone.parent ? zone_url(parent) : zones_url)
  end


  # def index
  #   @zones = Zone.roots
  # end

  # def show
  #   @zone = Zone.find(params[:id])
  # end

  # def new
  # end

  # def create
  # end


  # def zones_create
  #   @parent = Zone.find_by_id(params[:id])
  #   if @parent
  #     @natures = ZoneNature.find(:all, :conditions=>["parent_id=?", @parent.nature_id ], :order=>:name) 
  #   else
  #     @natures = ZoneNature.find(:all, :conditions=>["parent_id IS NULL"], :order=>:name) 
  #   end
  #   @parents = (@parent.nil? ? [] : @parent.parents)

  #   if request.post?
  #     @zone = Zone.new(params[:zone])
  #     @zone.parent_id = @parent.id if @parent
  #     @zone.save
  #   else
  #     @zone = Zone.new
  #     @zone.country_id = @parent.country_id if @parent
  #   end
  #   @zones = Zone.find(:all, :conditions=>(params[:id].nil? ? "parent_id IS NULL" : ["parent_id=?", params[:id]]), :order=>:name)
  # end



  def refresh
    zones = Zone.roots
    for zone in zones
      zone.save
    end
    redirect_to zones_url
  end

end
