# == Schema Information
#
# Table name: sale_lines
#
#  amount       :decimal(16, 2 default(0.0), not null
#  created_at   :datetime      
#  description  :text          
#  id           :integer       not null, primary key
#  lock_version :integer       default(0)
#  name         :string(255)   not null
#  product_id   :integer       not null
#  quantity     :decimal(16, 2 default(0.0), not null
#  sale_id      :integer       not null
#  unit_amount  :decimal(16, 2 default(0.0), not null
#  updated_at   :datetime      
#

class SaleLine < ActiveRecord::Base
  attr_accessor :password
  belongs_to :product
  belongs_to :sale
  has_many :guests
  has_one :subscription


  def before_validation
    if self.product
      self.unit_amount = self.product.amount
      self.name ||= self.product.name
      self.description ||= self.product.description
    end
    self.quantity ||= 0.0
    self.quantity = self.guests.count if self.product.personal?
    self.quantity = 0.0 if self.quantity < 0
    self.amount = self.quantity * self.unit_amount
  end
  
  def validate
    if self.product.storable?
      errors.add(:quantity, :less_than_or_equal_to, :count=>self.product.current_quantity) if self.quantity > self.product.current_quantity
    end
  end 

  def after_save
    self.sale.save
  end

  def after_destroy
    self.sale.save
  end

end
