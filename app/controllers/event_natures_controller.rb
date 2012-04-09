class EventNaturesController < ApplicationController
  # GET /event_natures
  # GET /event_natures.json
  def index
    @event_natures = EventNature.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event_natures }
    end
  end

  # GET /event_natures/1
  # GET /event_natures/1.json
  def show
    @event_nature = EventNature.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event_nature }
    end
  end

  # GET /event_natures/new
  # GET /event_natures/new.json
  def new
    @event_nature = EventNature.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event_nature }
    end
  end

  # GET /event_natures/1/edit
  def edit
    @event_nature = EventNature.find(params[:id])
  end

  # POST /event_natures
  # POST /event_natures.json
  def create
    @event_nature = EventNature.new(params[:event_nature])

    respond_to do |format|
      if @event_nature.save
        format.html { redirect_to @event_nature, notice: 'Event nature was successfully created.' }
        format.json { render json: @event_nature, status: :created, location: @event_nature }
      else
        format.html { render action: "new" }
        format.json { render json: @event_nature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_natures/1
  # PUT /event_natures/1.json
  def update
    @event_nature = EventNature.find(params[:id])

    respond_to do |format|
      if @event_nature.update_attributes(params[:event_nature])
        format.html { redirect_to @event_nature, notice: 'Event nature was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event_nature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_natures/1
  # DELETE /event_natures/1.json
  def destroy
    @event_nature = EventNature.find(params[:id])
    @event_nature.destroy

    respond_to do |format|
      format.html { redirect_to event_natures_url }
      format.json { head :no_content }
    end
  end
end
