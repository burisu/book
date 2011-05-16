class AddReceivedToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :received, :boolean, :null=>false, :default=>false
  end

  def self.down
    remove_column :payments, :received
  end
end
