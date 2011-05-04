class Version < ActiveRecord::Migration
  def self.up

    create_table :person_versions do |t|
      t.column :person_id,         :integer, :references=>:people
      t.column :patronymic_name,   :string
      t.column :family_name,       :string
      t.column :family_id,         :integer, :references=>nil
      t.column :first_name,        :string
      t.column :second_name,       :string
      t.column :user_name,         :string
      t.column :photo,             :string
      t.column :country_id,        :integer, :references=>nil
      t.column :sex,               :string
      t.column :born_on,           :date
      t.column :address,           :text
      t.column :latitude,          :float
      t.column :longitude,         :float
      t.column :phone,             :string
      t.column :phone2,            :string
      t.column :fax,               :string
      t.column :mobile,            :string
      t.column :email,             :string
      t.column :replacement_email, :string
      t.column :hashed_password,   :string
      t.column :salt,              :string
      t.column :rotex_email,       :string
      t.column :validation,        :string
      t.column :is_validated,      :boolean
      t.column :is_locked,         :boolean
      t.column :is_user,           :boolean
      t.column :role_id,           :integer, :references=>nil
    end

    add_column :families, :active, :boolean, :null=>false, :default=>true
    add_column :families, :locked, :boolean, :null=>false, :default=>false

    add_column :images, :name, :string, :null=>false

  end

  def self.down
    remove_column :images, :name

    remove_column :families, :locked
    remove_column :families, :active

    drop_table :person_versions
  end
end
