# == Schema Information
#
# Table name: subscriptions
#
#  amount               :decimal(16, 2 not null
#  authorization_number :string(255)   
#  begun_on             :date          not null
#  bin6                 :string(255)   
#  card_expired_on      :date          
#  card_type            :string(255)   
#  country              :string(255)   
#  created_at           :datetime      not null
#  error_code           :string(255)   
#  finished_on          :date          not null
#  id                   :integer       not null, primary key
#  lock_version         :integer       default(0), not null
#  note                 :text          
#  number               :string(16)    
#  payer_country        :string(255)   
#  payment_mode         :string(255)   not null
#  payment_type         :string(255)   
#  person_id            :integer       not null
#  sequential_number    :string(255)   
#  signature            :string(255)   
#  state                :string(1)     default("I"), not null
#  transaction_number   :string(255)   
#  updated_at           :datetime      not null
#

class Subscription < ActiveRecord::Base
  PAYMENT_MODES = [["Chèque", 'check'], ["Espèce","cash"], ["Carte bancaire", "card"]]
  validates_uniqueness_of :number
  attr_readonly :number

  def self.transaction_columns
    return {:amount=>"M", :number=>"R", :authorization_number=>"A", :sequential_number=>"T", :payment_type=>"P", :card_type=>"C", :transaction_number=>"S", :country=>"Y", :error_code=>"E", :card_expired_on=>"D", :payer_country=>"I", :bin6=>"N", :signature=>"K"}
  end

  def before_validation_on_create
    last = self.class.find(:first, :order=>"id DESC")
    self.number = Time.now.to_i.to_s(36)+(last ? last.id+1 : 0).to_s(36).rjust(6, '0')
    self.number.upcase!
    return true
  end

  def validate
    errors.add(:payment_mode, :invalid) unless PAYMENT_MODES.collect{|x| x[1]}.include?(self.payment_mode)
  end

  def confirm
    self.update_attribute(:state, 'C')
  end

  def terminate
    self.update_attribute(:state, 'P')
  end

  def paid?
    self.state == 'P'
  end

  def state_label
    {"I"=>"Devis", "C"=>"Commande", "P"=>"Payée"}[self.state]
  end

  def payment_mode_label
    PAYMENT_MODES.detect{|x| x[1] == self.payment_mode}[0]
  end

end
