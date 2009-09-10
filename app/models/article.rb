# == Schema Information
# Schema version: 20090621154736
#
# Table name: articles
#
#  id           :integer         not null, primary key
#  title        :string(255)     not null
#  intro        :string(512)     not null
#  body         :text            not null
#  done_on      :date            
#  natures      :text            
#  status       :string(255)     default("W"), not null
#  document     :string(255)     
#  author_id    :integer         not null
#  language_id  :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer         default(0), not null
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


class Article < ActiveRecord::Base
  NATURES={:default=>"Pour les membres",
           :home=>"Page d'accueil",
           :blog=>"Morceaux choisis",
           :agenda=>"Agenda",
           :about_us=>"A propos de nous (unique)",
           :contact=>"Contact (unique)",
           :legals=>"Mentions légales (unique)"}
    
  list_column :natures, NATURES
    
  STATUS = {:W=>"À l'écriture", :R=>"Prêt", :P=>"Publié", :C=>"À la correction", :U=>"Dépublié"}
  
  def content
    self.intro+"\n\n"+self.body
  end

  def created_on
    created_at.to_date
  end

  def to_correct
    self.update_attribute(:status, 'C')
  end

  def to_publish
    self.update_attribute(:status, 'R')
  end

  def publish
    self.update_attribute(:status, 'P')
  end
  
  def unpublish
    self.update_attribute(:status, 'U')
  end
  
  def ready?
    status=='R'
  end
  
  def locked?
    ["R","P","U"].include? self.status
  end  
  
  def human_status
    STATUS[self.status.to_sym]
  end
  
  def self.status
    STATUS.to_a.collect{|x| [x[1],x[0].to_s]}
  end
  
  def agenda
    self.natures_include? :agenda
  end
  def home
    self.natures_include? :home
  end
  def contact
    self.natures_include? :contact
  end
  def about_us
    self.natures_include? :about_us
  end
  def legals
    self.natures_include? :legals
  end
  def blog
    self.natures_include? :blog
  end

end

