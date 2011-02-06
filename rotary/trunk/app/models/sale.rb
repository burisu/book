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
  apply_simple_captcha :message => "Le texte est différent de l'image de vérification", :add_to_base => true
  validates_uniqueness_of :number
  attr_readonly :number
  attr_accessor :client_email_confirmation
  validates_confirmation_of :client_email


  def before_validation_on_create
    self.state ||= STATES[0][1]
    if self.client
      self.client_email_confirmation = self.client_email = self.client.email
    end
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
  
  # Identifiant utilisé par les contrôleurs 
  def to_param
    self.number
  end
  
  def saleable_lines_for(person=nil)
    for product in Product.saleable_to(person)
      self.lines.create(:product_id=>product.id, :quantity=>0) unless self.lines.find_by_product_id(product.id)
    end
    self.reload
    return self.lines
  end

  
end
