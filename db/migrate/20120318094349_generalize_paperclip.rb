# coding: utf-8
# require 'ftools'

class GeneralizePaperclip < ActiveRecord::Migration

  CHANGES = [
             {:table=>:images, :column=>:document, :destination=>:private},
             {:table=>:people, :column=>:photo,    :destination=>:private}
            ]
  
  ORIGINAL = "original".freeze

  def up
    cmd = []

    for change in CHANGES
      table, column, destination = change[:table], change[:column], change[:destination]

      fdir = Rails.root.join("public", "files", table.to_s.singularize, column.to_s)
      pdir = (destination == :public ? Rails.root.join("public", "system", table.to_s, column.to_s.pluralize) : Rails.root.join("private", table.to_s, column.to_s.pluralize))
      FileUtils.makedirs(pdir)

      cmd << "rake paperclip:refresh CLASS=#{table.to_s.classify}"
      if File.exist? fdir
        Dir.chdir fdir
        for id in Dir.glob("*").select{|f| !f.match(/^tmp$/)}  # Lists 1/ 2/ 5/ 6/ 8/ 15/ directories
          Dir.chdir(File.join(fdir, id)) do
            if original = Dir.glob("*").select{|f| !File.directory?(f)}[0] # Find truc.ext without tiny/ small/
              File.makedirs ORIGINAL
              File.move original, ORIGINAL
            end
          end
          File.move id, pdir
        end
        FileUtils.rm_rf fdir
      end

      
      rename_column table, column, "#{column}_file_name"
      add_column table, "#{column}_file_size", :integer
      add_column table, "#{column}_content_type", :string
      add_column table, "#{column}_updated_at", :datetime
    end
    
    say "Execute this to refresh DB: `#{cmd.uniq.join(' ; ')}`"
  end

  def down

    for change in CHANGES.reverse
      table, column, destination = change[:table], change[:column], change[:destination]

      remove_column table, "#{column}_updated_at"
      remove_column table, "#{column}_content_type"
      remove_column table, "#{column}_file_size"
      rename_column table, "#{column}_file_name", column

      fdir = Rails.root.join("public", "files", table.to_s.singularize, column.to_s)
      pdir = (destination == :public ? Rails.root.join("public", "system", table.to_s, column.to_s.pluralize) : Rails.root.join("private", table.to_s, column.to_s.pluralize))
      FileUtils.makedirs(fdir)
 
      if File.exist? pdir
        Dir.chdir pdir
        for id in Dir.glob("*").select{|f| !f.match(/^tmp$/)}  # Lists 1/ 2/ 5/ 6/ 8/ 15/ directories
          Dir.chdir(File.join(pdir, id)) do
            FileUtils.mv Dir.glob(File.join(ORIGINAL, "*")), "."
            FileUtils.rm_rf ORIGINAL
          end
          File.move id, fdir
        end
        FileUtils.rm_rf pdir
      end
      
    end
  end
end
