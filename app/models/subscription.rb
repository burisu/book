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
#  paid                 :boolean       not null
#  payer_country        :string(255)   
#  payment_mode         :string(255)   not null
#  payment_type         :string(255)   
#  person_id            :integer       not null
#  sequential_number    :string(255)   
#  signature            :string(255)   
#  transaction_number   :string(255)   
#  updated_at           :datetime      not null
#

class Subscription < ActiveRecord::Base
  PAYMENT_MODES = [["Chèque",'check'], ["Espèce","cash"], ["Virement","transfer"], ["Carte bancaire", "card"]]

  def before_validation
    last = self.class.find(:first, :order=>"id DESC")
    self.number = Time.now.to_i.to_s(36)+(last ? last.id+1 : 0).to_s(36).rjust(6, '0')
    self.number.upcase!

  end

end
