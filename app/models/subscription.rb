# == Schema Information
# Schema version: 20090409220615
#
# Table name: subscriptions
#
#  id           :integer         not null, primary key
#  begun_on     :date            not null
#  finished_on  :date            not null
#  amount       :decimal(16, 2)  not null
#  payment_mode :string(255)     not null
#  note         :text            
#  person_id    :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
#

class Subscription < ActiveRecord::Base
  PAYMENT_MODES = [["Chèque",'check'], ["Espèce","cash"],["Virement","transfer"]]
end
