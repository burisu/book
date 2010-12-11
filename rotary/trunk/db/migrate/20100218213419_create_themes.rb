class CreateThemes < ActiveRecord::Migration
  def self.up
    create_table :themes do |t|
      t.column :name,    :string, :null=>false
      t.column :color,   :string, :null=>false, :default=>"#808080"
      t.column :comment, :text
    end
    execute "INSERT INTO themes(name, created_at, updated_at) SELECT 'Par défaut', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP"

    add_column :questions, :theme_id, :integer
    execute "UPDATE questions SET theme_id=1"
  end

  def self.down
    remove_column :questions, :theme_id
    drop_table :themes
  end
end
