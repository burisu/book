class App < ActiveRecord::Migration
  def self.up

#                    S U P E R   A D M I N I S T R A T O R

  
    create_table :sessions,:row_version => false do |t|
      t.column :session_id,        :string, :references => nil
      t.column :data,              :text
      t.column :updated_at,        :datetime
    end
    add_index :sessions, :session_id
    add_index :sessions, :updated_at

#                         A D M I N I S T R A T O R

    create_table :languages do |t|
      t.column :name,              :string, :null=>false
      t.column :native_name,       :string
      t.column :iso639,            :string, :limit=>2, :null=>false
    end

    create_table :countries do |t|
      t.column :name,              :string, :null=>false
      t.column :native_name,       :string
      t.column :iso3166,           :string, :limit=>2, :null=>false
      t.column :language_id,       :integer, :null=>false , :references=>:languages, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :countries, :iso3166, :unique=>true
    add_index :countries, :name, :unique=>true

    create_table :zone_natures do |t|
      t.column :name,              :string,  :null=>false
      t.column :parent_id,         :integer, :references=>:zone_natures, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :zone_natures, :name, :unique=>true

    create_table :mandate_natures do |t|
      t.column :name,              :string, :null=>false
      t.column :code,              :string, :null=>false, :limit=>4
      t.column :zone_nature_id,    :integer, :references=>:zone_natures, :on_delete=>:restrict, :on_update=>:restrict
      t.column :parent_id,         :integer, :references=>:mandate_natures, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :mandate_natures, :name, :unique=>true
    add_index :mandate_natures, :code, :unique=>true

    create_table :zones do |t| # Club,District etc...
      t.column :name,              :string,  :null=>false
      t.column :number,            :integer, :null=>false
      t.column :code,              :text,    :null=>false
      t.column :nature_id,         :integer, :references=>:zone_natures, :on_delete=>:restrict, :on_update=>:restrict
      t.column :parent_id,         :integer, :references=>:zones, :on_delete=>:restrict, :on_update=>:restrict
      t.column :country_id,        :integer, :references=>:countries, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :zones, :name, :unique=>true
    add_index :zones, [:number, :parent_id], :unique=>true


    create_table :roles do |t|
      t.column :name,              :string,  :null=>false
      t.column :code,              :string,  :null=>false
      t.column :rights,            :text
    end
    add_index :roles, :code, :unique=>true
    add_index :roles, :name, :unique=>true
    add_index :roles, :rights


#                      S U B - A D M I N I S T R A T O R

    create_table :promotions do |t|
      t.column :name,              :string,   :null=>false #" 2005 Hemisphere Nord"
      t.column :is_outbound,       :boolean,  :null=>false, :default=>true # sortant
      t.column :from_code,         :string,   :null=>false, :default=>'N' # venant de l'hemisphère nord
    end
    add_index :promotions, :name, :unique=>true

    create_table :families do |t|
      t.column :title,             :string,  :limit=>512,  :null=>false
      t.column :country_id,        :integer, :null=>false, :references=>:countries, :on_delete=>:restrict, :on_update=>:restrict
      t.column :name,              :string,  :null=>false
      t.column :address,           :string,  :null=>false
      t.column :latitude,          :float
      t.column :longitude,         :float
      t.column :comment,           :text
      t.column :photo,             :string
    end
    add_index :families, :title, :unique=>true

#                      M A N A G E R


    create_table :people do |t|
      t.column :patronymic_name,   :string,  :null=>false
      t.column :family_name,       :string,  :null=>false  #Nom d'usage (=patro if sex='h')
      t.column :family_id,         :integer, :references=>:families, :on_delete=>:restrict, :on_update=>:restrict
      t.column :first_name,        :string,  :null=>false
      t.column :second_name,       :string
      t.column :user_name,         :string,  :null=>false, :limit=>32
      t.column :photo,             :string
      t.column :country_id,        :integer, :null=>false, :references=>:countries, :on_delete=>:restrict, :on_update=>:restrict
      t.column :sex,               :string,  :null=>false, :limit=>1 # M/H="homme", F="femne"
      t.column :born_on,           :date,    :null=>false
      t.column :address,           :text,    :null=>false
      t.column :latitude,          :float
      t.column :longitude,         :float
      t.column :phone,             :string,  :limit=>32
      t.column :phone2,            :string,  :limit=>32
      t.column :fax,               :string,  :limit=>32
      t.column :mobile,            :string,  :limit=>32
#      t.column :messenger_email,   :string
      t.column :email,             :string,  :null=>false
      t.column :replacement_email, :string
      t.column :hashed_password,   :string
      t.column :salt,              :string
      t.column :rotex_email,       :string
      t.column :validation,        :string
      t.column :is_validated,      :boolean, :null=>false, :default=>false 
      t.column :is_locked,         :boolean, :null=>false, :default=>false 
#      t.column :system,            :boolean, :null=>false, :default=>false
      t.column :is_user,           :boolean, :null=>false, :default=>false # peut se connecter ?
      t.column :role_id,           :integer, :null=>false, :references=>:roles, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :people, :user_name, :unique=>true
    add_index :people, :rotex_email, :unique=>true
    add_index :people, :is_validated
    add_index :people, :is_user
    add_index :people, :role_id
    add_index :people, :validation, :unique=>true

    create_table :mandates do |t|
      t.column :dont_expire,       :boolean, :null=>false, :default=>false
      t.column :begun_on,          :date,    :null=>false
      t.column :finished_on,       :date
      t.column :nature_id,         :integer, :null=>false, :references=>:mandate_natures, :on_delete=>:restrict, :on_update=>:restrict
      t.column :person_id,         :integer, :null=>false, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict
      t.column :zone_id,           :integer, :null=>false, :references=>:zones, :on_delete=>:restrict, :on_update=>:restrict
    end

    create_table :folders do |t| # dossier S_Exch de départ ou de retour
      t.column :person_id,            :integer, :null=>false, :references=>:people,     :on_delete=>:restrict, :on_update=>:restrict
      t.column :departure_country_id, :integer, :null=>false, :references=>:countries,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :arrival_country_id,   :integer, :null=>false, :references=>:countries,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :promotion_id,         :integer, :null=>false, :references=>:promotions, :on_delete=>:restrict, :on_update=>:restrict
      t.column :begun_on,             :date,    :null=>false
      t.column :finished_on,          :date,    :null=>false
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

    create_table :periods do |t|
      t.column :begun_on,          :date,    :null=>false
      t.column :finished_on,       :date,    :null=>false
      t.column :person_id,         :integer, :null=>false, :references=>:people,   :on_delete=>:restrict, :on_update=>:restrict
      t.column :folder_id,         :integer, :null=>false, :references=>:folders,  :on_delete=>:restrict, :on_update=>:restrict
      t.column :family_id,         :integer, :null=>false, :references=>:families, :on_delete=>:restrict, :on_update=>:restrict
      t.column :comment,           :text
    end

    create_table :articles do |t|
      t.column :title,             :string,  :null=>false
      t.column :title_h,           :text,    :null=>false
      t.column :intro,             :string,  :limit=>512, :null=>false
      t.column :intro_h,           :text,    :null=>false
      t.column :body,              :text,    :null=>false
      t.column :content_h,         :text,    :null=>false
      t.column :done_on,           :date
      t.column :natures,           :text
      t.column :document,          :string
      t.column :is_published,      :boolean, :null=>false, :default=>false
      t.column :author_id,         :integer, :null=>false, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict
      t.column :language_id,       :integer, :null=>false, :references=>:languages, :on_delete=>:restrict, :on_update=>:restrict
    end

    create_table :images do |t|
      t.column :title,             :string,  :null=>false
      t.column :title_h,           :text,    :null=>false
      t.column :desc,              :string
      t.column :desc_h,            :text
      t.column :document,          :string,  :null=>false
      t.column :person_id,         :integer, :null=>false, :references=>:people, :on_delete=>:restrict, :on_update=>:restrict
    end

    create_table :emails do |t|
      t.column :arrived_at,        :datetime, :null=>false
      t.column :sent_on,           :date,     :null=>false      
      t.column :subject,           :string,   :null=>false
#      t.column :echo,           :boolean,  :null=>false, :default=>false
      t.column :unvalid,           :boolean,  :null=>false, :default=>false
      t.column :from,              :text,     :null=>false
      t.column :from_valid,        :boolean,  :null=>false, :default=>false
      t.column :from_person_id,    :integer,  :references=>:people
      t.column :identifier,        :text,     :null=>false, :references=>nil
      t.column :to,                :text,     :references=>nil
      t.column :cc,                :text,     :references=>nil
      t.column :bcc,               :text,     :references=>nil
      t.column :manual_sent,       :boolean,  :null=>false, :default=>false
      t.column :sent_at,           :datetime
      t.column :message,           :text
    end
    add_index :emails, :identifier
    
    
    create_table :simple_captcha_data do |t|
      t.string :key, :limit => 40
      t.string :value, :limit => 6
    end

  end

  def self.down
#    drop_table :events
    drop_table :simple_captcha_data
    drop_table :emails
    drop_table :images
    drop_table :articles
#    drop_table :article_natures
    drop_table :periods
#    drop_table :families_people
    drop_table :folders
    drop_table :mandates
#    drop_table :person_versions
    drop_table :people
    drop_table :families
    drop_table :zones
    drop_table :zone_natures
    drop_table :mandate_natures
    drop_table :roles
    drop_table :promotions
    drop_table :countries
    drop_table :languages
    drop_table :sessions  
  end
end
