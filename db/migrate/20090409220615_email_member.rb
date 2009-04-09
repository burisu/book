class EmailMember < ActiveRecord::Migration
  def self.up
    remove_column :members, :email
    add_column :members, :email, :string
  end

  def self.down
    remove_column :members, :email
    add_column :members, :email, :string, :null=>false
  end
end
