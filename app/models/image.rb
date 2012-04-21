# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2012 Brice Texier, Thibaud Merigon
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
# 
# == Table: images
#
#  created_at            :datetime         not null
#  deleted               :boolean          not null
#  desc                  :string(255)      
#  desc_h                :text             
#  document_content_type :string(255)      
#  document_file_name    :string(255)      not null
#  document_file_size    :integer          
#  document_updated_at   :datetime         
#  id                    :integer          not null, primary key
#  lock_version          :integer          default(0), not null
#  locked                :boolean          not null
#  name                  :string(255)      not null
#  person_id             :integer          not null
#  published             :boolean          default(TRUE), not null
#  title                 :string(255)      not null
#  title_h               :text             not null
#  updated_at            :datetime         not null
#

# encoding: utf-8
class Image < ActiveRecord::Base
  belongs_to :person
  # TODO: Use paperclip
  # file_column :document, :magick => {:versions => { "thumb" => "128x128", "medium" => "600x450>", "big"=>"1024x768>" } }
  has_attached_file :document, :styles => { :thumb => "128x128", :medium => "600x450>", :big => "1024x768>"}

  validates_uniqueness_of :name

  before_validation do
    self.title_h = self.title.to_s
  end

  before_validation(:on=>:create) do
    self.name = self.title.to_s.lower_ascii.gsub(/\W/, '').to_s
    # while Image.find(:first, :conditions=>['id!=? AND name=?', self.id||0, self.name])
    while Image.find_by_name(self.name)
      self.name.succ!
    end
  end

  def deletable?
    reg = "\{\{[^\}]*#{self.name}[^\}]*[\|\}]+"
    Article.find(:all, :conditions=>["intro ~ ? OR body ~ ? ", reg, reg]).size <= 0 ? true : false
  end

end
