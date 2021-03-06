# 
desc "Update models list file in lib/models.rb"
task :models => :environment do
  print " - Models: "
  
  Dir.glob(Rails.root.join("app", "models", "*.rb")).each { |file| require file }
  # models = Object.subclasses_of(ActiveRecord::Base).select{|x| not x.name.match('::')}.sort{|a,b| a.name <=> b.name}
  models = ActiveRecord::Base.subclasses.select{|x| not x.name.match('::') and not x.abstract_class?}.sort{|a,b| a.name <=> b.name}
  models_code = "  @@models = ["+models.collect{|m| ":"+m.name.underscore}.join(", ")+"]\n"
  
  symodels = models.collect{|x| x.name.underscore.to_sym}

  errors = 0
  models_file = Rails.root.join("lib", "ekylibre", "models.rb")
  require models_file
  refs = Ekylibre.references
  refs_code = ""
  for model in models
    m = model.name.underscore.to_sym
    cols = []
    model.columns.sort{|a,b| a.name<=>b.name}.each do |column|
      c = column.name.to_sym
      if c.to_s.match(/_id$/)
        val = (refs[m].is_a?(Hash) ? refs[m][c] : nil)
        val = ((val.nil? or val.blank?) ? "''" : val.inspect)
        if c == :parent_id
          val = ":#{m}"
        elsif [:creator_id, :updater_id, :responsible_id].include? c
          val = ":user"
        elsif model.columns_hash.keys.include?(c.to_s[0..-4]+"_type")
          val = "\"#{c.to_s[0..-4]}_type\""
        elsif symodels.include? c.to_s[0..-4].to_sym
          val = ":#{c.to_s[0..-4]}"
        end
        errors += 1 if val == "''"
        cols << "      :#{c} => #{val}"
      end
    end
    refs_code += "\n    :#{m} => {\n"+cols.join(",\n")+"\n    },"
  end
  print "#{errors} errors\n"
  refs_code = "  @@references = {"+refs_code[0..-2]+"\n  }\n"

  File.open(models_file, "wb") do |f|
    f.write("# Autogenerated from Ekylibre (`rake clean:models` or `rake clean`)\n")
    f.write("module Ekylibre\n")
    f.write("  mattr_reader :models, :references\n")
    f.write("  # List of all models\n")
    f.write(models_code)
    f.write("\n  # List of all references\n")
    f.write(refs_code)
    f.write("\n")
    f.write("end\n")
  end

end
