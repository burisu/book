require 'scaffolding_extensions'

class AdminController < ApplicationController
  ssl_only
  scaffold_all_models
end
