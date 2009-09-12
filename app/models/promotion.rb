# == Schema Information
#
# Table name: promotions
#
#  created_at   :datetime      not null
#  from_code    :string(255)   default("N"), not null
#  id           :integer       not null, primary key
#  is_outbound  :boolean       default(TRUE), not null
#  lock_version :integer       default(0), not null
#  name         :string(255)   not null
#  updated_at   :datetime      not null
#

class Promotion < ActiveRecord::Base
end
