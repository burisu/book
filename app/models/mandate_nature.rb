# encoding: utf-8
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
# == Table: mandate_natures
#
#  created_at      :datetime         not null
#  group_nature_id :integer          
#  id              :integer          not null, primary key
#  lock_version    :integer          default(0), not null
#  name            :string(255)      not null
#  rights          :text             
#  updated_at      :datetime         not null
#


class MandateNature < ActiveRecord::Base
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_length_of :name, :allow_nil => true, :maximum => 255
  validates_presence_of :name
  #]VALIDATORS]
  # belongs_to :parent, :class_name=>MandateNature.name
  belongs_to :group_nature
  has_many :mandates, :foreign_key => :nature_id
  has_and_belongs_to_many :articles

  # RIGHTS = {:all=>"Administrator", 
  #   :home=>"Manage articles of the home page",
  #   :blog=>"Gérer les articles de blog",
  #   :promotions=>"Gérer les promotions",
  #   :suivi=>"Gérer les questionnaires et les réponses",
  #   :publishing=>"Can edit and publish blog articles",
  #   :users=>"Manage accounts",
  #   :folders=>"Manage folders",
  #   :subscribing=>"Valid or refuse subcriptions only",
  #   :mandates=>"Manage mandates of people",
  #   :agenda=>"Manage articles of the agenda",
  #   :specials=>"Manage special articles"
  # }

  class << self
    def rights_file; Rails.root.join("config", "rights.yml"); end
    def minimum_right; :__minimum__; end
    def rights; @@rights; end
    def rights_list; @@rights_list; end
    def useful_rights; @@useful_rights; end
  end


  def self.rights_for(controller, action)
    return ((self.rights[controller.to_sym] || {})[action.to_sym]) || []
  end

  def human_rights
    self.rights.to_s.strip.split(/\s+/).collect{|r|'<em>'+::I18n.translate("rights.#{r}")+'</em>'}.to_sentence
  end

  def to_param
    self.code
  end


  # list_column :rights, RIGHTS

  before_validation do
    self.rights = self.rights_string
  end

  def self.initialize_rights
    definition = YAML.load_file(self.rights_file)
    # Expand actions
    for right, attributes in definition
      if attributes
        attributes['actions'].each_index do |index|
          unless attributes['actions'][index].match(/\:\:/)
            attributes['actions'][index] = attributes['controller'].to_s+"::"+attributes['actions'][index] 
          end
        end if attributes['actions'].is_a? Array
      end
    end
    definition.delete_if{|k, v| k == "__not_used__" }
    @@rights_list = definition.keys.sort.collect{|x| x.to_sym}.delete_if{|k, v| k.to_s.match(/^\_\_.*\_\_$/)}
    @@rights = {}
    @@useful_rights = {}
    for right, attributes in definition
      if attributes.is_a? Hash
        unless attributes["controller"].blank?
          controller = attributes["controller"].to_sym
          @@useful_rights[controller] ||= []
          @@useful_rights[controller] << right.to_sym
        end
        for uniq_action in attributes["actions"]
          controller, action = uniq_action.split(/\W+/)[0..1].collect{|x| x.to_sym}
          @@rights[controller] ||= {}
          @@rights[controller][action] ||= []
          @@rights[controller][action] << right.to_sym
        end if attributes["actions"].is_a? Array
      end
    end
  end
  
  self.initialize_rights

  
end
