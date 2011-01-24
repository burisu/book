# == Schema Information
#
# Table name: payments
#
#  amount               :decimal(16, 2 default(0.0), not null
#  authorization_number :string(255)   
#  bin6                 :string(255)   
#  card_expired_on      :date          
#  card_type            :string(255)   
#  country              :string(255)   
#  created_at           :datetime      
#  error_code           :string(255)   
#  id                   :integer       not null, primary key
#  lock_version         :integer       default(0)
#  mode                 :string(255)   not null
#  number               :string(16)    
#  payer_country        :string(255)   
#  payer_email          :string(255)   not null
#  payer_id             :integer       
#  payment_type         :string(255)   
#  sequential_number    :string(255)   
#  signature            :string(255)   
#  transaction_number   :string(255)   
#  updated_at           :datetime      
#  used_amount          :decimal(16, 2 default(0.0), not null
#

class Payment < ActiveRecord::Base
end
