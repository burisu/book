class CreateEmails < ActiveRecord::Migration
  def self.up


  end

  def self.down
    drop_table :emails
  end
end
