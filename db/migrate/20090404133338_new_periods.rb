class NewPeriods < ActiveRecord::Migration
  def self.up
    add_column :periods, :family_name, :string, :null=>false
    add_column :periods, :address, :string, :null=>false
    add_column :periods, :country_id, :integer, :references=>:countries
    add_column :periods, :latitude, :float
    add_column :periods, :longitude, :float
    add_column :periods, :photo, :string
    add_column :periods, :phone, :string,  :limit=>32
    add_column :periods, :fax, :string,  :limit=>32
    add_column :periods, :email, :string,  :limit=>32
    add_column :periods, :mobile, :string,  :limit=>32

    remove_column :periods, :family_id

    rename_table :families, :old_families

    create_table :members do |t|
      t.column :last_name,       :string,  :null=>false
      t.column :first_name,        :string,  :null=>false
      t.column :photo,             :string 
      t.column :nature,            :string,  :null=>false, :limit=>8 # human dog cat other
      t.column :other_nature,      :string
      t.column :sex,               :string,  :null=>false, :limit=>1 # M/H="homme", F="femne", U="Inconnu"
      t.column :phone,             :string,  :limit=>32
      t.column :fax,               :string,  :limit=>32
      t.column :mobile,            :string,  :limit=>32
      t.column :email,             :string,  :null=>false    
      t.column :comment,           :text
      t.column :person_id,         :integer, :null=>false, :references=>:people
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end
    add_index :members, :person_id

    create_table :members_periods do |t|
      t.column :member_id,         :integer, :null=>false, :references=>:members
      t.column :period_id,         :integer, :null=>false, :references=>:periods
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end
    add_index :members_periods, [:member_id, :period_id], :unique=>true
    add_index :members_periods, :member_id
    add_index :members_periods, :period_id

  end

  def self.down
    drop_table :members_periods
    drop_table :members
    
    rename_table :old_families, :families

    add_column :periods, :family_id, :integer, :references=>:families

    remove_column :periods, :family_name
    remove_column :periods, :address
    remove_column :periods, :country_id
    remove_column :periods, :latitude
    remove_column :periods, :longitude
    remove_column :periods, :photo
    remove_column :periods, :phone
    remove_column :periods, :fax
    remove_column :periods, :email
    remove_column :periods, :mobile
  end
end
