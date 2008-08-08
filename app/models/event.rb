class Event < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  def before_save
    self.desc_cache = textilize self.desc
  end
  
end
