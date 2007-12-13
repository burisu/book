class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.column :arrived_at,     :datetime, :null=>false
      t.column :sent_on,        :date,     :null=>false      
      t.column :subject,        :string,   :null=>false
      t.column :charset,        :string,   :null=>false
      t.column :header,         :text,     :null=>false
      t.column :unvalid,        :boolean,  :null=>false, :default=>false
      t.column :from,           :text,     :null=>false
      t.column :from_valid,     :boolean,  :null=>false, :default=>false
      t.column :from_ids,       :text,     :null=>false
      t.column :recipients,     :text,     :null=>false
      t.column :cc,             :text,     :references=>nil
      t.column :bcc,            :text,     :references=>nil
      t.column :receivers_good, :text,     :references=>nil
      t.column :receivers_bad,  :text,     :references=>nil
      t.column :receivers_ids,  :text,     :references=>nil
      t.column :manual_sent,    :boolean,  :null=>false, :default=>false
      t.column :sent_at,        :datetime
    end
  end

  def self.down
    drop_table :emails
  end
end
