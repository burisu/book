# == Schema Information
#
# Table name: products
#
#  active                 :boolean       not null
#  amount                 :decimal(16, 2 default(0.0), not null
#  created_at             :datetime      
#  current_quantity       :decimal(16, 2 default(0.0), not null
#  deadlined              :boolean       not null
#  description            :text          
#  id                     :integer       not null, primary key
#  initial_quantity       :decimal(16, 2 default(0.0), not null
#  lock_version           :integer       default(0)
#  name                   :string(255)   not null
#  password               :string(255)   
#  passworded             :boolean       not null
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
  has_many :guests
  has_many :sale_lines

  named_scope :usable, :conditions=>["active AND NOT deadlined OR (deadlined AND CURRENT_DATE BETWEEN started_on AND stopped_on)"], :order=>:name
  named_scope :saleable_to, lambda { |p|
    {:conditions=>["active AND (subscribing = ? OR subscribing IS FALSE) AND NOT deadlined OR (deadlined AND CURRENT_DATE BETWEEN started_on AND stopped_on)", !p.nil?], :order=>:name} 
  }

  named_scope :unusable, :conditions=>["NOT active OR (deadlined AND NOT CURRENT_DATE BETWEEN started_on AND stopped_on)"], :order=>:name


  def before_validation
    self.personal = false if self.subscribing?
    return true
  end
  
  def empty_stock?
    # return (self.storable? and SaleLine.sum(:quantity, :joins=>:sale, :conditions=>["product_id=? AND sale.state IN (?)", self.id, ['C', 'P']])<= self.initial_quantity) or not self.storable?
    return ((self.storable? and self.current_quantity > 0) or not self.storable? ? true : false)
  end
  
end
