# == Schema Information
#
# Table name: mandate_natures
#
#  code           :string(8)     not null
#  created_at     :datetime      
#  id             :integer       not null, primary key
#  lock_version   :integer       default(0)
#  name           :string(255)   not null
#  parent_id      :integer       
#  rights         :text          
#  updated_at     :datetime      
#  zone_nature_id :integer       
#

module ActiveRecord
  class Base
    def self.list_column(column, reference)
      code = ''
      col = column.to_s
      if reference.is_a? Hash
        reflist = "#{col}_keys".upcase
        code += "#{reflist} = {"+reference.collect{|x| ":"+x[0].to_s+"=>\""+x[1].to_s+"\""}.join(",")+"}\n"
      else
        reflist = reference.to_s
      end
      code << <<-"end_eval"
        def #{col}_include?(key)
          raise(Exception.new("Only Symbol are accepted")) unless key.is_a?(Symbol)
          return false unless #{reflist}.include?(key)
          return !self.#{col}.to_s.match("(\ |^)"+key.to_s+"(\ |$)").nil?
        end
        def #{col}_add(key)
          raise(Exception.new("Only Symbol are accepted")) unless key.is_a?(Symbol)
          return self.#{col} unless #{reflist}.include?(key)
          self.#{col} = self.class.#{col}_string(self.#{col}_array << key)
        end
        def #{col}_remove(key)
          raise(Exception.new("Only Symbol are accepted")) unless key.is_a?(Symbol)
          return self.#{col} unless #{reflist}.include?(key)
          array = self.#{col}_array
          array.delete(key)
          self.#{col} = self.class.#{col}_string(array)
        end
        def #{col}_set(key, add = true)
          if add
            return #{col}_add(key)
          else
            return #{col}_remove(key)
          end 
        end
        def #{col}_array
          self.#{col}.to_s.split(" ").collect{|key| key.to_sym if #{reflist}.include?(key.to_sym)}.compact
        end
        def self.#{col}_string(array=nil)
          array = self.#{col}_array if array.nil?
          " "+array.flatten.uniq.sort{|x,y| x.to_s<=>y.to_s}.join(" ")+" "
        end
        def #{col}_string
          self.class.#{col}_string(self.#{col}_array)
        end
        end_eval
        #      ActionController::Base.logger.error(code)
        class_eval(code)
    end
    
  end
end


class MandateNature < ActiveRecord::Base

  RIGHTS = {:all=>"Administrator", 
    :home=>"Manage articles of the home page",
    :blog=>"Gérer les articles de blog",
    :promotions=>"Manage promotions",
    :suivi=>"Manage questionnaires and answers",
    :publishing=>"Can edit and publish blog articles",
    :users=>"Manage accounts",
    :folders=>"Manage folders",
    :subscribing=>"Valid or refuse subcriptions only",
    :mandates=>"Manage mandates of people",
    :agenda=>"Manage articles of the agenda",
    :specials=>"Manage special articles"
  }

  list_column :rights, RIGHTS

  def before_validation
    self.rights = self.rights_string
  end
  
end
