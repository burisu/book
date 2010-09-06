# == Schema Information
#
# Table name: promotions
#
#  created_at   :datetime      
#  from_code    :string(255)   default("N"), not null
#  id           :integer       not null, primary key
#  is_outbound  :boolean       default(TRUE), not null
#  lock_version :integer       default(0)
#  name         :string(255)   not null
#  updated_at   :datetime      
#

class Promotion < ActiveRecord::Base
  def code
    self.name.gsub(/\s+/,'')
  end
end
