class AddPersonApprobation < ActiveRecord::Migration
  def self.up
    add_column :people, :approved, :boolean, :null=>false, :default=>false
    execute "UPDATE people SET approved=true"
    add_column :person_versions, :approved, :boolean
  end

  def self.down
    remove_column :person_versions, :approved
    remove_column :people, :approved
  end
end
