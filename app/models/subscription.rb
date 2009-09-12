# == Schema Information
#
# Table name: subscriptions
#
#  amount       :decimal(16, 2 not null
#  begun_on     :date          not null
#  created_at   :datetime      not null
#  finished_on  :date          not null
#  id           :integer       not null, primary key
#  lock_version :integer       default(0), not null
#  note         :text          
#  payment_mode :string(255)   not null
#  person_id    :integer       not null
#  updated_at   :datetime      not null
#

class Subscription < ActiveRecord::Base
  PAYMENT_MODES = [["Chèque",'check'], ["Espèce","cash"],["Virement","transfer"]]
end
