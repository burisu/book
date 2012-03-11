class UpdateProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :active, :boolean, :null=>false, :default=>false
    execute "UPDATE products SET active = true"
    add_column :products, :passworded, :boolean, :null=>false, :default=>false
    add_column :products, :password, :string
    
  end

  def self.down
    remove_column :products, :password
    remove_column :products, :passworded
    remove_column :products, :active
  end
end
