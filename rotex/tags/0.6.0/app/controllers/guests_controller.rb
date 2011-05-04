# -*- coding: utf-8 -*-
class GuestsController < ApplicationController


  def new
    @guest = Guest.new
    @title = "Nouvel invité"
    render_form
  end

  def create
    @guest = Guest.new(params[:guest])
    @guest.sale_line_id = params[:line_id]
    if @guest.save
      redirect_to fill_sale_url(@guest.sale)
    end
    @title = "Nouvel invité"
    render_form
  end

  def edit
    @guest = Guest.find(params[:id])
    @title = "Modifier l'invité #{@guest.label}"
    render_form
  end

  def update
    @guest = Guest.find(params[:id])
    @title = "Modifier l'invité #{@guest.label}"
    if @guest.update_attributes(params[:guest])
      redirect_to fill_sale_url(@guest.sale)
    end
    render_form
  end

  def destroy
    guest = Guest.find(params[:id])
    guest.destroy
    redirect_to fill_sale_url(guest.sale)
  end


end
