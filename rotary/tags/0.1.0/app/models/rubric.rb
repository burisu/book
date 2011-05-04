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
  belongs_to :parent, :class_name=>Rubric.name
  has_many :articles
  validates_uniqueness_of :code

  def before_validation
    self.code = self.name if self.code.blank?
    self.code = self.code.to_s.parameterize
  end

  def to_param
    self.code
  end
end
