class EmailMember < ActiveRecord::Migration
  def self.up
    remove_column :members, :email
    add_column :members, :email, :string
    remove_column :members_periods, :id
  end

  def self.down
    add_column :members_periods, :id, :integer
    remove_column :members, :email
    add_column :members, :email, :string
  end
end
