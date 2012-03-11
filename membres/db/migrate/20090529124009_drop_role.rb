class DropRole < ActiveRecord::Migration
  def self.up
    add_column :mandate_natures, :rights, :text
    change_column :mandate_natures, :code, :string, :limit=>8
    change_column_null :mandates, :zone_id, true

    execute "INSERT INTO mandate_natures (name, code, rights, created_at, updated_at) SELECT name, code, rights, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM roles WHERE LENGTH(TRIM(rights))>0"
    execute "INSERT INTO mandates (dont_expire, created_at, updated_at, begun_on, nature_id, person_id) SELECT true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_DATE, mn.id, p.id FROM people p JOIN roles r ON (p.role_id=r.id) JOIN mandate_natures mn ON (mn.code=r.code)"

    remove_column :people, :role_id
    drop_table :roles
  end

  def self.down
    create_table :roles do |t|
      t.column :name,              :string,  :null=>false
      t.column :code,              :string,  :null=>false
      t.column :rights,            :text
    end
    add_index :roles, :code, :unique=>true
    add_index :roles, :name, :unique=>true
    add_index :roles, :rights

    add_column :people, :role_id, :integer, :references=>:roles
    
    execute "INSERT INTO roles (name, code, rights, created_at, updated_at) SELECT name, code, rights, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM mandate_natures WHERE LENGTH(TRIM(rights))>0"
    execute "UPDATE people SET role_id=r.id FROM mandates m JOIN mandate_natures mn ON (nature_id=mn.id) JOIN roles r ON (mn.code=r.code) WHERE m.person_id=people.id"
    execute "DELETE FROM mandates WHERE nature_id IN (SELECT id FROM mandate_natures WHERE code in (SELECT code FROM roles))"
    execute "DELETE FROM mandate_natures WHERE code in (SELECT code FROM roles)"

    remove_column :mandate_natures, :rights
  end
end
