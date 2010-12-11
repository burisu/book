class AddStudent < ActiveRecord::Migration
  def self.up
    add_column :people, :student, :boolean, :null=>false, :default=>false
    add_column :person_versions, :student, :boolean, :null=>false, :default=>false
    execute "UPDATE people SET student=true"
  end

  def self.down
    remove_column :person_versions, :student
    remove_column :people, :student
  end
end
