class Correct < ActiveRecord::Migration
  def self.up
    remove_index :zones, :name
    add_index :zones, ["name", "parent_id"]
  end

  def self.down
    remove_index :zones, :column=>["name", "parent_id"]
    add_index :zones, :name
  end
end
