class CreateEventNatures < ActiveRecord::Migration
  def change
    create_table :event_natures do |t|
      t.string :name
      t.text :comment

      t.timestamps
    end
  end
end
