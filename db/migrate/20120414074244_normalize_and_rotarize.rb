# -*- coding: utf-8 -*-
class NormalizeAndRotarize < ActiveRecord::Migration
  CONTACT_NATURES = {
    :address => {:name => 'Adresse personnelle'},
    :email => {:name => 'E-mail personnel', :preserve=>true},
    :fax => {:name => 'Fax personnel'},
    :mobile => {:name => 'Mobile personnel', :canal=>:phone},
    :phone => {:name => 'Téléphone personnel'},
    :phone2 => {:name => 'Téléphone professionnel', :canal=>:phone}
  }.each_with_index do |x, i| 
    x[1][:id] = i+1
    x[1][:canal] ||= x[0]
  end.freeze

  def up

    create_table :person_contact_natures do |t|
      t.string :name, :null=>false
      t.string :canal, :null=>false
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end
    add_index :person_contact_natures, :canal

    for k, nature in CONTACT_NATURES
      execute "INSERT INTO person_contact_natures (id, name, canal, created_at, updated_at) VALUES (#{nature[:id]}, #{quote(nature[:name])}, #{quote(nature[:canal])}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    end
    reset_sequence! :person_contact_natures, :id

    create_table :person_contacts do |t|
      t.belongs_to :person, :null=>false
      t.belongs_to :nature, :null=>false
      t.string :canal, :null=>false
      t.string :address, :null=>false
      t.string :line_2   #, :limit => 38
      t.string :line_3   #, :limit => 38
      t.string :line_4   #, :limit => 38
      t.string :line_5   #, :limit => 38
      t.string :line_6   #, :limit => 38
      t.string :postcode #, :limit => 38
      t.string :city     #, :limit => 38
      t.string :country  #, :limit => 38
      t.boolean :receiving, :null=>false, :default=>false
      t.boolean :sending, :null=>false, :default=>false
      t.boolean :by_default, :null=>false, :default=>false
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end
    add_index :person_contacts, :person_id
    add_index :person_contacts, :nature_id
    add_index :person_contacts, :canal

    for column, nature in CONTACT_NATURES.dup.delete_if{|k,v| v[:canal] != :address}
      execute "INSERT INTO person_contacts (person_id, nature_id, canal, address, line_2, line_3, line_4, line_5, line_6, country, receiving, sending, created_at, updated_at) SELECT id, #{nature[:id]}, #{quote(nature[:canal])}, REPLACE(#{column}, E'\\n', ', '), SPLIT_PART(#{column}, E'\\n', 1), SPLIT_PART(#{column}, E'\\n', 2), SPLIT_PART(#{column}, E'\\n', 3), SPLIT_PART(#{column}, E'\\n', 4), SPLIT_PART(#{column}, E'\\n', 5), country, true, true, created_at, updated_at FROM people WHERE LENGTH(TRIM(#{column})) > 0"
      remove_column :people, column unless nature[:preserve]
    end

    for column, nature in CONTACT_NATURES.dup.delete_if{|k,v| v[:canal] == :address}
      execute "INSERT INTO person_contacts (person_id, nature_id, canal, address, country, receiving, sending, created_at, updated_at) SELECT id, #{nature[:id]}, #{quote(nature[:canal])}, #{column}, country, true, true, created_at, updated_at FROM people WHERE LENGTH(TRIM(#{column})) > 0"
      remove_column :people, column unless nature[:preserve]
    end

    rename_column :people, :country, :birth_country

    create_table :sectors do |t|
      t.string :name
      t.string :code
      t.text :description
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end

    create_table :activities do |t|
      t.belongs_to :sector, :null=>false
      t.string :label
      t.string :name
      t.string :code
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end
    add_index :activities, :sector_id

    create_table :organigrams do |t|
      t.string :name
      t.string :code
      t.text :description
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end    

    create_table :activities_organigrams, :id=>false do |t|
      t.belongs_to :activity, :null=>false
      t.belongs_to :organigram, :null=>false
    end    
    add_index :activities_organigrams, :activity_id
    add_index :activities_organigrams, :organigram_id
    
    create_table :organigram_professions do |t|
      t.belongs_to :organigram
      t.string :name
      t.boolean :printed, :null=>false, :default=>false
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0
    end    
    add_index :organigram_professions, :organigram_id

    add_column :people, :activity_id, :integer
    add_column :people, :profession_id, :integer

    create_table :honour_natures do |t|
      t.string :name
      t.text :description
      t.text :comment
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0      
    end

    create_table :honours do |t|
      t.belongs_to :nature
      t.string :name
      t.string :abbreviation
      t.integer :position
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0      
    end
    add_index :honours, :nature_id

    create_table :person_honours do |t|
      t.belongs_to :person, :null=>false
      t.belongs_to :honour, :null=>false
      t.date :given_on
      t.text :comment
      t.timestamps
      t.integer :lock_version, :null=>false, :default=>0      
    end
    add_index :person_honours, :person_id
    add_index :person_honours, :honour_id

    drop_table :simple_captcha_data

    rename_table :questions, :question_items
    rename_table :questionnaires, :questions
    rename_column :question_items, :questionnaire_id, :question_id
    rename_column :answers, :questionnaire_id, :question_id
    rename_column :answer_items, :question_id, :question_item_id

    rename_column :group_kinships, :children_id, :child_id
  end

  def down
    rename_column :group_kinships, :child_id, :children_id

    rename_column :answer_items, :question_item_id, :question_id
    rename_column :answers, :question_id, :questionnaire_id
    rename_column :question_items, :question_id, :questionnaire_id
    rename_table :questions, :questionnaires
    rename_table :question_items, :questions

    create_table "simple_captcha_data", :force => true do |t|
      t.string   "key",          :limit => 40
      t.string   "value",        :limit => 6
      t.datetime "created_at",                                :null => false
      t.datetime "updated_at",                                :null => false
      t.integer  "lock_version",               :default => 0, :null => false
    end

    drop_table :person_honours
    drop_table :honours
    drop_table :honour_natures

    remove_column :people, :activity_id
    remove_column :people, :profession_id
    drop_table :organigram_professions
    drop_table :activities_organigrams
    drop_table :organigrams
    drop_table :activities
    drop_table :sectors

    rename_column :people, :birth_country, :country

    for column, nature in CONTACT_NATURES
      unless nature[:preserve]
        add_column :people, column, :string  
        execute "UPDATE people SET #{column} = pc.address FROM person_contacts AS pc WHERE pc.person_id = people.id AND pc.nature_id = #{nature[:id]}"
      end
    end

    drop_table :person_contacts
    drop_table :person_contact_natures
  end
end
