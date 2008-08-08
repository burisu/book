class App < ActiveRecord::Migration
  def self.up
  
      create_table :sessions,:row_version => false do |t|
      t.column :session_id, :string, :references => nil
      t.column :data, :text
      t.column :updated_at, :datetime
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at

    create_table :promotions do |t|
      t.column :name, :string, :null=>false #" 2005 Hemisphere Nord"
      t.column :is_outbound, :boolean, :null=>false, :default=>true # sortant
      t.column :comes_from_north, :boolean, :null=>false, :default=>true # venant de l'hemisphère nord
    end
    add_index :promotions, :name, :unique=>true

    create_table :roles do |t|
      t.column :name, :string, :null=>false
      t.column :restriction_level, :integer, :null=>false, :default=>1000 # 0=root, 1000=SimpleMembre
    end
    add_index :roles, :name, :unique=>true

    create_table :mandate_natures do |t|
      t.column :name, :string, :null=>false
      t.column :code, :string, :null=>false, :limit=>4
      t.column :parent_id, :integer, :references=>:mandate_natures, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :mandate_natures, :name, :unique=>true
    add_index :mandate_natures, :code, :unique=>true

    create_table :languages do |t|
      t.column :name, :string, :null=>false
      t.column :native_name, :string
      t.column :iso639, :string, :limit=>2, :null=>false
    end

    create_table :countries do |t|
      t.column :name, :string, :null=>false
      t.column :native_name, :string
      t.column :iso3166, :string, :limit=>2, :null=>false
      t.column :language_id, :integer, :null=>false , :references=>:languages, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :countries, :iso3166, :unique=>true
    add_index :countries, :name, :unique=>true

    create_table :zone_natures do |t|
      t.column :name, :string, :null=>false
      t.column :parent_id, :integer, :references=>:zone_natures, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :zone_natures, :name, :unique=>true

    create_table :zones do |t| # Club,District etc...
      t.column :name, :string, :null=>false
      t.column :number, :integer, :null=>false
      t.column :code, :text, :null=>false
      t.column :nature_id, :integer, :references=>:zone_natures, :on_delete=>:restrict, :on_update=>:restrict
      t.column :parent_id, :integer, :references=>:zones, :on_delete=>:restrict, :on_update=>:restrict
      t.column :country_id, :integer, :references=>:countries, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :zones, :name, :unique=>true
    add_index :zones, [:number, :parent_id], :unique=>true

    create_table :people do |t|
      t.column :patronymic_name, :string, :null=>false
      t.column :family_name, :string  #Nom épouse
      t.column :first_name, :string, :null=>false
      t.column :second_name, :string
      t.column :system, :boolean, :null=>false, :default=>false
      t.column :is_female, :boolean, :null=>false, :default=>true #false="male", true="femelle"
      t.column :born_on, :date, :null=>false
      t.column :home_address, :text, :null=>false
      t.column :aligned_to_right, :boolean, :null=>false, :default=>false
      t.column :home_phone, :string, :limit=>32
      t.column :work_phone, :string, :limit=>32
      t.column :fax, :string, :limit=>32
      t.column :mobile, :string, :limit=>32
      t.column :messenger_email, :string
      t.column :user_name, :string, :null=>false, :limit=>32
      t.column :email, :string, :null=>false
      t.column :replacement_email, :string
      t.column :hashed_password, :string
      t.column :salt, :string
      t.column :rotex_email, :string
      t.column :validation, :string
      t.column :is_validated, :boolean, :null=>false, :default=>false 
      t.column :is_locked, :boolean, :null=>false, :default=>false 
      t.column :photo, :string
      t.column :country_id, :integer, :null=>false, :references=>:countries, :on_delete=>:restrict, :on_update=>:restrict
      t.column :role_id, :integer, :null=>false, :references=>:roles, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :people, :user_name, :unique=>true
    add_index :people, :rotex_email, :unique=>true
#    add_index :people, :email, :unique=>true
    add_index :people, :hashed_password, :unique=>true
    add_index :people, :is_validated
    add_index :people, :validation, :unique=>true

    create_table :person_versions do |t|
      t.column :patronymic_name, :string, :null=>false
      t.column :family_name, :string  #Nom épouse
      t.column :first_name, :string, :null=>false
      t.column :second_name, :string
      t.column :is_female, :boolean, :null=>false, :default=>true #false="male", true="femelle"
      t.column :born_on, :date, :null=>false
      t.column :home_address, :text, :null=>false
      t.column :aligned_to_right, :boolean, :null=>false, :default=>false
      t.column :home_phone, :string, :limit=>32
      t.column :work_phone, :string, :limit=>32
      t.column :fax, :string, :limit=>32
      t.column :mobile, :string, :limit=>32
      t.column :messenger_email, :string
      t.column :user_name, :string, :null=>false, :limit=>32
      t.column :email, :string, :null=>false
      t.column :hashed_password, :string
      t.column :salt, :string
      t.column :rotex_email, :string
      t.column :is_locked, :boolean, :null=>false, :default=>false 
      t.column :photo, :string
      t.column :country_id, :integer, :null=>false, :references=>:countries, :on_delete=>:restrict, :on_update=>:restrict
      t.column :role_id, :integer, :null=>false, :references=>:roles, :on_delete=>:restrict, :on_update=>:restrict
      t.column :person_id, :integer, :null=>false, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :person_versions, :rotex_email, :unique=>true
    add_index :person_versions, :hashed_password, :unique=>true

    create_table :mandates do |t|
      t.column :begun_on, :date, :null=>false
      t.column :finished_on, :date
      t.column :nature_id, :integer, :null=>false, :references=>:mandate_natures, :on_delete=>:restrict, :on_update=>:restrict
      t.column :person_id, :integer, :null=>false, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict
      t.column :zone_id, :integer, :null=>false, :references=>:zones, :on_delete=>:restrict, :on_update=>:restrict

    end

    create_table :folders do |t| # dossier S_Exch de départ ou de retour
      t.column :departure_country_id, :integer, :null=>false, :references=>:countries,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :arrival_country_id,   :integer, :null=>false, :references=>:countries,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :person_id,            :integer, :null=>false, :references=>:people,     :on_delete=>:restrict, :on_update=>:restrict
      t.column :promotion_id,         :integer, :null=>false, :references=>:promotions, :on_delete=>:restrict, :on_update=>:restrict
      t.column :host_zone_id,         :integer, :null=>false, :references=>:zones,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :sponsor_zone_id,      :integer, :null=>false, :references=>:zones,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :proposer_zone_id,     :integer, :null=>false, :references=>:zones,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :arrival_person_id,    :integer, :null=>false, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict #YEO D'arrivee
      t.column :departure_person_id,  :integer, :null=>false, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict  #YEO depart
      t.column :begun_on,             :date,    :null=>false
      t.column :finished_on,          :date,    :null=>false
      t.column :comment, :text
    end
#    add_index :folders, :is_given
#    add_index :folders, :is_accepted

    create_table :families do |t|
      t.column :code, :integer, :null=>false
      t.column :comment, :text
      t.column :photo, :string #nom de fichier de la photo
    end
    add_index :families, :code, :unique=>true

    create_table :families_people do |t|
      t.column :person_id, :integer, :null=>false, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict
      t.column :family_id, :integer, :null=>false, :references=>:families, :on_delete=>:restrict, :on_update=>:restrict
    end

    create_table :periods do |t|
      t.column :begun_on, :date, :null=>false
      t.column :finished_on, :date, :null=>false
      t.column :folder_id, :integer, :null=>false, :references=>:folders, :on_delete=>:restrict, :on_update=>:restrict
      t.column :family_id, :integer, :null=>false, :references=>:families, :on_delete=>:restrict, :on_update=>:restrict
      t.column :comment, :text
    end

    create_table :article_natures do |t|
      t.column :name, :string, :null=>false
      t.column :code, :string, :null=>false, :limit=>8
    end

    create_table :articles do |t|
      t.column :title, :string, :null=>false
      t.column :intro, :string, :null=>false
      t.column :content, :text, :null=>false
      t.column :summary, :string,:limit=>512
      t.column :html_intro, :text
      t.column :html_content, :text
      t.column :html_summary, :text
      t.column :nature_id, :integer, :null=>false, :references=>:article_natures, :on_delete=>:restrict, :on_update=>:restrict
      t.column :author_id, :integer, :null=>false, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict
      t.column :language_id, :integer, :null=>false, :references=>:languages, :on_delete=>:restrict, :on_update=>:restrict
    end


    create_table :emails do |t|
      t.column :arrived_at,     :datetime, :null=>false
      t.column :sent_on,        :date,     :null=>false      
      t.column :subject,        :string,   :null=>false
#      t.column :echo,           :boolean,  :null=>false, :default=>false
      t.column :unvalid,        :boolean,  :null=>false, :default=>false
      t.column :from,           :text,     :null=>false
      t.column :from_valid,     :boolean,  :null=>false, :default=>false
      t.column :from_person_id, :integer,  :references=>:people
      t.column :identifier,     :text,     :null=>false, :references=>nil
      t.column :to,             :text,     :references=>nil
      t.column :cc,             :text,     :references=>nil
      t.column :bcc,            :text,     :references=>nil
      t.column :manual_sent,    :boolean,  :null=>false, :default=>false
      t.column :sent_at,        :datetime
      t.column :message,        :text
    end
    add_index :emails, :identifier

    create_table :simple_captcha_data do |t|
      t.string :key, :limit => 40
      t.string :value, :limit => 6
    end

    create_table :events do |t|
      t.column :title, :string, :null=>false
      t.column :done_on, :date, :null=>false
      t.column :desc, :text
      t.column :desc_cache, :text
    end

  end

  def self.down
    drop_table :events
    drop_table :simple_captcha_data
    drop_table :emails
    drop_table :articles
    drop_table :article_natures
    drop_table :periods
    drop_table :families_people
    drop_table :families
    drop_table :folders
    drop_table :mandates
    drop_table :person_versions
    drop_table :people
    drop_table :zones
    drop_table :zone_natures
    drop_table :countries
    drop_table :languages
    drop_table :mandate_natures
    drop_table :roles
    drop_table :promotions
    drop_table :sessions  
  end
end
