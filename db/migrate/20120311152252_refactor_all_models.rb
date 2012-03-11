class RefactorAllModels < ActiveRecord::Migration

  def change
    # People / Mandates
    rename_column :mandates, :begun_on, :started_on
    rename_column :mandates, :finished_on, :stopped_on
    rename_column :mandates, :zone_id, :group_id

    remove_column :mandate_natures, :code
    remove_column :mandate_natures, :parent_id
    remove_column :mandate_natures, :zone_nature_id
    add_column :mandate_natures, :group_nature_id, :integer

    # Groups / Zones
    rename_table :zones, :groups

    rename_column :groups, :nature_id, :zone_nature_id

    create_table :organizations do |t|
      t.string :name
      t.text :description
      t.text :comment
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end

    create_table :group_natures do |t|
      t.string :name
      t.references :organization
      t.references :zone_nature
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end
    add_index :group_natures, :organization_id
    add_index :group_natures, :zone_nature_id

    create_table :group_natures_groups, :id=>false do |t|
      t.references :group_nature
      t.references :group
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end
    add_index :group_natures_groups, :group_nature_id
    add_index :group_natures_groups, :group_id

    create_table :group_kinships do |t|
      t.references :parent
      t.references :children
      t.references :organization
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end
    add_index :group_kinships, :parent_id
    add_index :group_kinships, :children_id
    add_index :group_kinships, :organization_id

    # Events / Interventions
    create_table :events do |t|
      t.string :name
      t.text :place
      t.text :description
      t.text :comment
      t.datetime :started_at
      t.datetime :stopped_at
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end

    create_table :group_intervention_natures do |t|
      t.string :name
      t.text :description
      t.text :comment
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end

    create_table :group_interventions do |t|
      t.references :nature
      t.references :group
      t.references :event
      t.datetime :started_at
      t.datetime :stopped_at
      t.text :description
      t.text :comment
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end
    add_index :group_interventions, :nature_id 
    add_index :group_interventions, :group_id 
    add_index :group_interventions, :event_id 

    create_table :person_intervention_natures do |t|
      t.string :name
      t.text :description
      t.text :comment
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end

    create_table :person_interventions do |t|
      t.references :nature
      t.references :person
      t.references :event
      t.references :group_intervention
      t.datetime :started_at
      t.datetime :stopped_at
      t.text :description
      t.text :comment
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end
    add_index :person_interventions, :nature_id 
    add_index :person_interventions, :person_id 
    add_index :person_interventions, :event_id 
    add_index :person_interventions, :group_intervention_id 

  end

end
