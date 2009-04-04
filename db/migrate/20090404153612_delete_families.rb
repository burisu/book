class DeleteFamilies < ActiveRecord::Migration
  def self.up
    drop_table :old_families
  end

  def self.down
    create_table :old_families do |t|
      t.column :title,             :string,  :limit=>512,  :null=>false
      t.column :country_id,        :integer, :null=>false, :references=>:countries, :on_delete=>:restrict, :on_update=>:restrict
      t.column :name,              :string,  :null=>false
      t.column :address,           :string,  :null=>false
      t.column :latitude,          :float
      t.column :longitude,         :float
      t.column :comment,           :text
      t.column :photo,             :string
      t.column :active, :boolean, :null=>false, :default=>true
      t.column :locked, :boolean, :null=>false, :default=>false
    end
    add_index :old_families, :title, :unique=>true
  end
end
