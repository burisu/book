class MergeFoldersWithPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :arrival_country_id,   :integer, :references=>:countries
    add_column :people, :arrival_person_id,    :integer, :references=>:people
    add_column :people, :started_on,           :date
    add_column :people, :stopped_on,           :date
    add_column :people, :comment,              :text
    add_column :people, :departure_country_id, :integer, :references=>:countries
    add_column :people, :departure_person_id,  :integer, :references=>:people
    add_column :people, :host_zone_id,         :integer, :references=>:zones
    add_column :people, :promotion_id,         :integer, :references=>:promotions
    add_column :people, :proposer_zone_id,     :integer, :references=>:zones
    add_column :people, :sponsor_zone_id,      :integer, :references=>:zones
    add_index :people, :arrival_country_id
    add_index :people, :departure_country_id
    add_index :people, :host_zone_id
    add_index :people, :promotion_id
    add_index :people, :proposer_zone_id
    add_index :people, :sponsor_zone_id
    add_index :people, :started_on
    add_index :people, :stopped_on

    add_column :person_versions, :arrival_country_id,   :integer, :references=>:countries
    add_column :person_versions, :arrival_person_id,    :integer, :references=>:people
    add_column :person_versions, :started_on,           :date
    add_column :person_versions, :stopped_on,           :date
    add_column :person_versions, :comment,              :text
    add_column :person_versions, :departure_country_id, :integer, :references=>:countries
    add_column :person_versions, :departure_person_id,  :integer, :references=>:people
    add_column :person_versions, :host_zone_id,         :integer, :references=>:zones
    add_column :person_versions, :promotion_id,         :integer, :references=>:promotions
    add_column :person_versions, :proposer_zone_id,     :integer, :references=>:zones
    add_column :person_versions, :sponsor_zone_id,      :integer, :references=>:zones

    
    execute "UPDATE people SET arrival_country_id=f.arrival_country_id, arrival_person_id=f.arrival_person_id, started_on=f.begun_on, stopped_on=f.finished_on, comment=f.comment, departure_country_id=f.departure_country_id, departure_person_id=f.departure_person_id, host_zone_id=f.host_zone_id, promotion_id=f.promotion_id, proposer_zone_id=f.proposer_zone_id, sponsor_zone_id=f.sponsor_zone_id FROM folders AS f WHERE f.person_id=people.id"


    execute "UPDATE periods SET person_id=f.person_id  FROM folders AS f WHERE f.id=periods.folder_id"
    remove_column :periods, :folder_id

    drop_table :folders
  end

  def self.down
    create_table :folders do |t| # dossier S_Exch de départ ou de retour
      t.column :person_id,            :integer, :null=>false, :references=>:people,     :on_delete=>:restrict, :on_update=>:restrict
      t.column :departure_country_id, :integer, :references=>:countries,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :arrival_country_id,   :integer, :references=>:countries,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :promotion_id,         :integer, :null=>false, :references=>:promotions, :on_delete=>:restrict, :on_update=>:restrict
      t.column :begun_on,             :date
      t.column :finished_on,          :date    
      t.column :host_zone_id,         :integer, :references=>:zones,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :sponsor_zone_id,      :integer, :references=>:zones,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :proposer_zone_id,     :integer, :references=>:zones,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :departure_person_id,  :integer, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict # YEO depart
      t.column :arrival_person_id,    :integer, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict # YEO arrivee
      t.column :comment, :text
    end
    add_index :folders, :person_id
    add_index :folders, :departure_country_id
    add_index :folders, :arrival_country_id
    add_index :folders, :promotion_id
    add_index :folders, :begun_on
    add_index :folders, :finished_on

    execute "INSERT INTO folders (person_id, arrival_country_id, arrival_person_id, begun_on, finished_on, comment, departure_country_id, departure_person_id, host_zone_id, promotion_id, proposer_zone_id, sponsor_zone_id) SELECT id, arrival_country_id, arrival_person_id, started_on, stopped_on, comment, departure_country_id, departure_person_id, host_zone_id, promotion_id, proposer_zone_id, sponsor_zone_id FROM people WHERE promotion_id IS NOT NULL"

    add_column :periods, :folder_id, :integer, :references=>:folders
    execute "UPDATE periods SET folder_id=f.id  FROM folders AS f WHERE f.person_id=periods.person_id"


    remove_column :person_versions, :arrival_country_id
    remove_column :person_versions, :arrival_person_id
    remove_column :person_versions, :started_on
    remove_column :person_versions, :stopped_on
    remove_column :person_versions, :comment
    remove_column :person_versions, :departure_country_id
    remove_column :person_versions, :departure_person_id
    remove_column :person_versions, :host_zone_id
    remove_column :person_versions, :promotion_id
    remove_column :person_versions, :proposer_zone_id
    remove_column :person_versions, :sponsor_zone_id

    remove_column :people, :arrival_country_id
    remove_column :people, :arrival_person_id
    remove_column :people, :started_on
    remove_column :people, :stopped_on
    remove_column :people, :comment
    remove_column :people, :departure_country_id
    remove_column :people, :departure_person_id
    remove_column :people, :host_zone_id
    remove_column :people, :promotion_id
    remove_column :people, :proposer_zone_id
    remove_column :people, :sponsor_zone_id
  end
end
