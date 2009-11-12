# == Schema Information
#
# Table name: rubrics
#
#  code          :string(255)   not null
#  created_at    :datetime      
#  description   :text          
#  id            :integer       not null, primary key
#  lock_version  :integer       default(0)
#  logo          :string(255)   
#  name          :string(255)   not null
#  parent_id     :integer       
#  rubrics_count :integer       default(0), not null
#  updated_at    :datetime      
#

class Rubric < ActiveRecord::Base
end
