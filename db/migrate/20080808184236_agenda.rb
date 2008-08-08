class Agenda < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :title, :string, :null=>false
      t.column :done_on, :date, :null=>false
      t.column :desc, :text
      t.column :desc_cache, :text
    end
  end

  def self.down
    drop_table :events
  end
end
