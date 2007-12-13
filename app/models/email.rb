# == Schema Information
# Schema version: 4
#
# Table name: emails
#
#  id             :integer       not null, primary key
#  arrived_at     :datetime      not null
#  send_on        :date          not null
#  subject        :string(255)   not null
#  charset        :string(255)   not null
#  header         :text          not null
#  unvalid        :boolean       not null
#  from           :text          not null
#  from_valid     :boolean       not null
#  from_ids       :text          not null
#  recipients     :text          not null
#  cc             :text          
#  bcc            :text          
#  receivers_good :text          
#  receivers_bad  :text          
#  receivers_ids  :text          
#  manual_sent    :boolean       not null
#  sent_at        :datetime      
#  created_at     :datetime      not null
#  updated_at     :datetime      not null
#  lock_version   :integer       default(0), not null
#

class Email < ActiveRecord::Base

end
