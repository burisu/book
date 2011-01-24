# == Schema Information
#
# Table name: sales
#
#  amount       :decimal(16, 2 
#  client_email :string(255)   not null
#  client_id    :integer       
#  comment      :text          
#  created_at   :datetime      
#  created_on   :date          not null
#  id           :integer       not null, primary key
#  lock_version :integer       default(0)
#  number       :string(255)   not null
#  payment_id   :integer       
#  state        :string(255)   not null
#  updated_at   :datetime      
#

class Sale < ActiveRecord::Base
  STATES = [["Devis", 'I'], ["Commande","C"], ["Payée", "P"]]
  validates_uniqueness_of :number
  attr_readonly :number


  def before_validation_on_create
    last = self.class.find(:first, :order=>"id DESC")
    self.number = Time.now.to_i.to_s(36)+(last ? last.id+1 : 0).to_s(36).rjust(6, '0')
    self.number.upcase!
    return true
  end

  def before_save
    @deliver_mail = false
    old_self = self.class.find_by_id(self.id.to_i)
    if (old_self.nil? or (old_self.is_a?(self.class) and old_self.state != self.state)) and self.state == "P"
      @deliver_mail = true
    end
  end
  
  def after_save
    if @deliver_mail
      Maily.deliver_has_subscribed(self.person, self)
      Maily.deliver_notification(:has_subscribed, self.person, self.responsible)
    end
  end

  def confirm
    self.update_attribute(:state, 'C')
  end

  def terminate
    unless self.person.approved?
      Maily.deliver_notification(:approval, self.person)
    end
    self.update_attribute(:state, 'P')
  end

  def paid?
    self.state == 'P'
  end

  def state_label
    {"I"=>"Devis", "C"=>"Commande", "P"=>"Payée"}[self.state]
  end

  def state_class
    {"I"=>"error", "C"=>"warning", "P"=>"notice"}[self.state]
  end

  
end
