class ConfigurationsController < ApplicationController
  # ssl_only

  def edit
    @configuration = @@configuration
    @title = "Configuration du site"
    render_form
  end

  def update
    @configuration = @@configuration
    @configuration.attributes = params[:configuration]
    @configuration.save
    @title = "Configuration du site"
    render_form
  end

end
