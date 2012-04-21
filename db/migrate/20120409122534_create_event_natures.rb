class CreateEventNatures < ActiveRecord::Migration
  def change
    create_table :event_natures do |t|
      t.string :name
      t.text :comment
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end

    add_column :events, :nature_id, :integer, :null => false
  end
end
