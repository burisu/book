MODEL_DIR   = File.join(Rails.root.to_s, "app/models")
FIXTURE_DIR = File.join(Rails.root.to_s, "test/fixtures")
UNIT_DIR = File.join(Rails.root.to_s, "test/unit")

def validable_column?(column)
  return ![:created_at, :creator_id, :creator, :updated_at, :updater_id, :updater, :position, :lock_version].include?(column.name.to_sym)
end


def search_missing_validations(klass)
  code = ""
  
  columns = klass.content_columns.delete_if{|c| !validable_column?(c)}.sort{|a,b| a.name.to_s <=> b.name.to_s}
  
  cs = columns.select{|c| c.type == :integer}
  code << "  validates_numericality_of "+cs.collect{|c| ":#{c.name}"}.join(', ')+", :allow_nil => true, :only_integer => true\n" if cs.size > 0
  
  cs = columns.select{|c| c.number? and c.type != :integer}
  code << "  validates_numericality_of "+cs.collect{|c| ":#{c.name}"}.join(', ')+", :allow_nil => true\n" if cs.size > 0
  
  limits = columns.select{|c| c.text? and c.limit}.collect{|c| c.limit}.uniq.sort
  for limit in limits
    cs = columns.select{|c| c.text? and c.limit == limit}
    code << "  validates_length_of "+cs.collect{|c| ":#{c.name}"}.join(', ')+", :allow_nil => true, :maximum => #{limit}\n"
  end
  
  cs = columns.select{|c| not c.null and c.type == :boolean}
  code << "  validates_inclusion_of "+cs.collect{|c| ":#{c.name}"}.join(', ')+", :in => [true, false]\n" if cs.size > 0 # , :message => 'activerecord.errors.messages.blank'.to_sym
  
  needed = columns.select{|c| not c.null and c.type != :boolean}.collect{|c| ":#{c.name}"}
  needed += klass.reflect_on_all_associations(:belongs_to).select do |association| 
    column = klass.columns_hash[association.foreign_key.to_s]
    raise Exception.new("Problem in #{association.active_record.name} at '#{association.macro} :#{association.name}'") if column.nil?
    !column.null and validable_column?(column)
  end.collect{|r| ":#{r.name}"}
  code << "  validates_presence_of "+needed.sort.join(', ')+"\n" if needed.size > 0

  return code
end

desc "Adds default validations in models based on the schema"
task :validations=>:environment do
  log = File.open(Rails.root.join("log", "clean-validations.log"), "wb")

  models = []
  Dir.chdir(MODEL_DIR) do 
    models = Dir["**/*.rb"].sort
  end

  print " - Valids: "

  errors = []
  models.each do |m|
    class_name = m.sub(/\.rb$/,'').camelize
    begin
      klass = class_name.split('::').inject(Object){ |klass,part| klass.const_get(part) }
      if klass < ActiveRecord::Base && !klass.abstract_class?
        file = File.join(MODEL_DIR, klass.name.underscore + ".rb")

        # Get content
        content = nil
        File.open(file, "rb:UTF-8") do |f|
          content = f.read
        end

        # Look for tag
        tag_start = "#[VALIDATORS["
        tag_end = "#]VALIDATORS]"

        regexp = /\ *#{Regexp.escape(tag_start)}[^\A]*#{Regexp.escape(tag_end)}\ */x
        tag = regexp.match(content)

        # Compute (missing) validations
        validations = search_missing_validations(klass)
        next if validations.blank? and not tag

        # Create tag if it's necessary
        unless tag
          content.sub!(/(class\s#{klass.name}\s*<\s*(CompanyRecord|Ekylibre::Record::Base|ActiveRecord::Base))/, '\1'+"\n  #{tag_start}\n  #{tag_end}")
        end

        # Update tag
        content.sub!(regexp, "  "+tag_start+" Do not edit these lines directly. Use `rake clean:validations`.\n"+validations.to_s+"  "+tag_end)

        # Save file
        File.open(file, "wb") do |f|
          f.write content
        end

      end
    rescue Exception => e
      errors << e
      log.write("Unable to adds validations on #{class_name}: #{e.message}\n"+e.backtrace.join("\n"))
    end
  end
  print "#{errors.size.to_s.rjust(3)} errors\n"

  log.close
end

desc "Removes the validators contained betweens the tags"
task :empty_validations do
  models = Dir[Rails.root.join("app", "models", "*.rb")].sort
  
  errors = []
  models.each do |file|
    class_name = file.split(/\/\\/)[-1].sub(/\.rb$/,'').camelize
    begin
      
      # Get content
      content = nil
      File.open(file, "rb:UTF-8") do |f|
        content = f.read
      end

      # Look for tag
      tag_start = "#[VALIDATORS["
      tag_end = "#]VALIDATORS]"

      regexp = /\ *#{Regexp.escape(tag_start)}[^\A]*#{Regexp.escape(tag_end)}\ */x
      tag = regexp.match(content)

      # Compute (missing) validations
      next unless tag

      # Update tag
      content.sub!(regexp, "  "+tag_start+"\n  "+tag_end)

      # Save file
      File.open(file, "wb") do |f|
        f.write content
      end      
    rescue Exception => e
      puts "Unable to adds validations on #{class_name}: #{e.message}\n"+e.backtrace.join("\n")
    end
  end
end
