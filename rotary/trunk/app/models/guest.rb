# == Schema Information
#
# Table name: guests
#
#  annotation   :text          
#  created_at   :datetime      
#  email        :string(255)   
#  first_name   :string(255)   
#  id           :integer       not null, primary key
#  last_name    :string(255)   
#  lock_version :integer       default(0)
#  product_id   :integer       
#  sale_id      :integer       
#  sale_line_id :integer       
#  updated_at   :datetime      
#  zone_id      :integer       
#

class Guest < ActiveRecord::Base
  belongs_to :product
  belongs_to :sale
  belongs_to :sale_line
  belongs_to :zone

  def before_validation
    if self.sale_line
      self.sale = self.sale_line.sale 
      self.product = self.sale_line.product
    end
  end

  def after_save
    self.sale_line.save
  end

  def after_destroy
    self.sale_line.save
  end

  def label
    "#{self.first_name} #{self.last_name}"
  end

end
