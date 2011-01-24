# == Schema Information
#
# Table name: products
#
#  amount                 :decimal(16, 2 default(0.0), not null
#  created_at             :datetime      
#  current_quantity       :decimal(16, 2 default(0.0), not null
#  deadlined              :boolean       not null
#  description            :text          
#  id                     :integer       not null, primary key
#  initial_quantity       :decimal(16, 2 default(0.0), not null
#  lock_version           :integer       default(0)
#  name                   :string(255)   not null
#  personal               :boolean       not null
#  started_on             :date          
#  stopped_on             :date          
#  storable               :boolean       not null
#  subscribing            :boolean       not null
#  subscribing_started_on :date          
#  subscribing_stopped_on :date          
#  unit                   :string(255)   default("unités"), not null
#  updated_at             :datetime      
#

class Product < ActiveRecord::Base
end
