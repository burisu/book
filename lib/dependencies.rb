module ActiveRecord
  class Base
    class_attribute :dependencies
    
    self.dependencies = []
      
    def self.depends_on(*models)
      self.dependencies += models.collect{|x| x.to_sym}
      self.dependencies.uniq!
    end

    def self.dependents
      array = []
      for ref in self.reflections.values.select
        klass = ref.class_name.constantize
        for lref in klass.reflections.values
          if lref.class_name == self.name and klass.dependencies.include?(lref.name)
            array << ref.class_name.underscore
          end
        end
      end
      return array 
    end

  end
end
