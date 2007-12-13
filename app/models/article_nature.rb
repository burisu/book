# == Schema Information
# Schema version: 4
#
# Table name: article_natures
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  code         :string(8)     not null
#  created_at   :datetime      not null
#  updated_at   :datetime      not null
#  lock_version :integer       default(0), not null
#

class ArticleNature < ActiveRecord::Base
end
