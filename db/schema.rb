# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 2) do

  create_table "article_natures", :force => true do |t|
    t.column "name",         :string,                               :null => false
    t.column "code",         :string,   :limit => 8,                :null => false
    t.column "created_at",   :datetime,                             :null => false
    t.column "updated_at",   :datetime,                             :null => false
    t.column "lock_version", :integer,               :default => 0, :null => false
  end

  create_table "articles", :force => true do |t|
    t.column "title",        :string,                                 :null => false
    t.column "intro",        :string,                                 :null => false
    t.column "content",      :text,                                   :null => false
    t.column "summary",      :string,   :limit => 512
    t.column "html_intro",   :text
    t.column "html_content", :text
    t.column "html_summary", :text
    t.column "nature_id",    :integer,                                :null => false
    t.column "author_id",    :integer,                                :null => false
    t.column "language_id",  :integer,                                :null => false
    t.column "created_at",   :datetime,                               :null => false
    t.column "updated_at",   :datetime,                               :null => false
    t.column "lock_version", :integer,                 :default => 0, :null => false
  end

  create_table "countries", :force => true do |t|
    t.column "name",         :string,                               :null => false
    t.column "native_name",  :string
    t.column "iso3166",      :string,   :limit => 2,                :null => false
    t.column "language_id",  :integer,                              :null => false
    t.column "created_at",   :datetime,                             :null => false
    t.column "updated_at",   :datetime,                             :null => false
    t.column "lock_version", :integer,               :default => 0, :null => false
  end

  add_index "countries", ["name"], :name => "index_countries_on_name", :unique => true

  create_table "emails", :force => true do |t|
    t.column "arrived_at",     :datetime,                    :null => false
    t.column "sent_on",        :date,                        :null => false
    t.column "subject",        :string,                      :null => false
    t.column "unvalid",        :boolean,  :default => false, :null => false
    t.column "from",           :text,                        :null => false
    t.column "from_valid",     :boolean,  :default => false, :null => false
    t.column "from_person_id", :integer
    t.column "identifier",     :text,                        :null => false
    t.column "to",             :text
    t.column "cc",             :text
    t.column "bcc",            :text
    t.column "manual_sent",    :boolean,  :default => false, :null => false
    t.column "sent_at",        :datetime
    t.column "message",        :text
    t.column "created_at",     :datetime,                    :null => false
    t.column "updated_at",     :datetime,                    :null => false
    t.column "lock_version",   :integer,  :default => 0,     :null => false
  end

  add_index "emails", ["identifier"], :name => "index_emails_on_identifier"

  create_table "families", :force => true do |t|
    t.column "code",         :integer,                 :null => false
    t.column "comment",      :text
    t.column "photo",        :string
    t.column "created_at",   :datetime,                :null => false
    t.column "updated_at",   :datetime,                :null => false
    t.column "lock_version", :integer,  :default => 0, :null => false
  end

  add_index "families", ["code"], :name => "index_families_on_code", :unique => true

  create_table "families_people", :force => true do |t|
    t.column "person_id",    :integer,                 :null => false
    t.column "family_id",    :integer,                 :null => false
    t.column "created_at",   :datetime,                :null => false
    t.column "updated_at",   :datetime,                :null => false
    t.column "lock_version", :integer,  :default => 0, :null => false
  end

  create_table "folders", :force => true do |t|
    t.column "name",                 :string,                  :null => false
    t.column "departure_country_id", :integer,                 :null => false
    t.column "arrival_country_id",   :integer,                 :null => false
    t.column "person_id",            :integer,                 :null => false
    t.column "promotion_id",         :integer,                 :null => false
    t.column "host_zone_id",         :integer,                 :null => false
    t.column "sponsor_zone_id",      :integer,                 :null => false
    t.column "proposer_zone_id",     :integer,                 :null => false
    t.column "arrival_person_id",    :integer,                 :null => false
    t.column "departure_person_id",  :integer,                 :null => false
    t.column "begun_on",             :date,                    :null => false
    t.column "finished_on",          :date,                    :null => false
    t.column "comment",              :text
    t.column "created_at",           :datetime,                :null => false
    t.column "updated_at",           :datetime,                :null => false
    t.column "lock_version",         :integer,  :default => 0, :null => false
  end

  add_index "folders", ["name"], :name => "index_folders_on_name", :unique => true

  create_table "languages", :force => true do |t|
    t.column "name",         :string,                               :null => false
    t.column "native_name",  :string
    t.column "iso639",       :string,   :limit => 2,                :null => false
    t.column "created_at",   :datetime,                             :null => false
    t.column "updated_at",   :datetime,                             :null => false
    t.column "lock_version", :integer,               :default => 0, :null => false
  end

  create_table "mandate_natures", :force => true do |t|
    t.column "name",         :string,                               :null => false
    t.column "code",         :string,   :limit => 4,                :null => false
    t.column "parent_id",    :integer
    t.column "created_at",   :datetime,                             :null => false
    t.column "updated_at",   :datetime,                             :null => false
    t.column "lock_version", :integer,               :default => 0, :null => false
  end

  add_index "mandate_natures", ["code"], :name => "index_mandate_natures_on_code", :unique => true
  add_index "mandate_natures", ["name"], :name => "index_mandate_natures_on_name", :unique => true

  create_table "mandates", :force => true do |t|
    t.column "begun_on",     :date,                    :null => false
    t.column "finished_on",  :date
    t.column "nature_id",    :integer,                 :null => false
    t.column "person_id",    :integer,                 :null => false
    t.column "zone_id",      :integer,                 :null => false
    t.column "created_at",   :datetime,                :null => false
    t.column "updated_at",   :datetime,                :null => false
    t.column "lock_version", :integer,  :default => 0, :null => false
  end

  create_table "people", :force => true do |t|
    t.column "patronymic_name",  :string,                                    :null => false
    t.column "family_name",      :string
    t.column "first_name",       :string,                                    :null => false
    t.column "second_name",      :string
    t.column "is_female",        :boolean,                :default => true,  :null => false
    t.column "born_on",          :date,                                      :null => false
    t.column "home_address",     :text,                                      :null => false
    t.column "aligned_to_right", :boolean,                :default => false, :null => false
    t.column "home_phone",       :string,   :limit => 32
    t.column "work_phone",       :string,   :limit => 32
    t.column "fax",              :string,   :limit => 32
    t.column "mobile",           :string,   :limit => 32
    t.column "messenger_email",  :string
    t.column "user_name",        :string,   :limit => 32,                    :null => false
    t.column "email",            :string,                                    :null => false
    t.column "hashed_password",  :string,                                    :null => false
    t.column "salt",             :string,                                    :null => false
    t.column "rotex_email",      :string
    t.column "is_locked",        :boolean,                :default => false, :null => false
    t.column "photo",            :string
    t.column "country_id",       :integer,                                   :null => false
    t.column "role_id",          :integer,                                   :null => false
    t.column "created_at",       :datetime,                                  :null => false
    t.column "updated_at",       :datetime,                                  :null => false
    t.column "lock_version",     :integer,                :default => 0,     :null => false
  end

  add_index "people", ["email"], :name => "index_people_on_email"
  add_index "people", ["hashed_password"], :name => "index_people_on_hashed_password", :unique => true
  add_index "people", ["rotex_email"], :name => "index_people_on_rotex_email", :unique => true

  create_table "periods", :force => true do |t|
    t.column "begun_on",     :date,                    :null => false
    t.column "finished_on",  :date,                    :null => false
    t.column "folder_id",    :integer,                 :null => false
    t.column "family_id",    :integer,                 :null => false
    t.column "comment",      :text
    t.column "created_at",   :datetime,                :null => false
    t.column "updated_at",   :datetime,                :null => false
    t.column "lock_version", :integer,  :default => 0, :null => false
  end

  create_table "person_versions", :force => true do |t|
    t.column "patronymic_name",  :string,                                    :null => false
    t.column "family_name",      :string
    t.column "first_name",       :string,                                    :null => false
    t.column "second_name",      :string
    t.column "is_female",        :boolean,                :default => true,  :null => false
    t.column "born_on",          :date,                                      :null => false
    t.column "home_address",     :text,                                      :null => false
    t.column "aligned_to_right", :boolean,                :default => false, :null => false
    t.column "home_phone",       :string,   :limit => 32
    t.column "work_phone",       :string,   :limit => 32
    t.column "fax",              :string,   :limit => 32
    t.column "mobile",           :string,   :limit => 32
    t.column "messenger_email",  :string
    t.column "user_name",        :string,   :limit => 32,                    :null => false
    t.column "email",            :string,                                    :null => false
    t.column "hashed_password",  :string,                                    :null => false
    t.column "salt",             :string,                                    :null => false
    t.column "rotex_email",      :string
    t.column "is_locked",        :boolean,                :default => false, :null => false
    t.column "photo",            :string
    t.column "country_id",       :integer,                                   :null => false
    t.column "role_id",          :integer,                                   :null => false
    t.column "person_id",        :integer,                                   :null => false
    t.column "created_at",       :datetime,                                  :null => false
    t.column "updated_at",       :datetime,                                  :null => false
    t.column "lock_version",     :integer,                :default => 0,     :null => false
  end

  add_index "person_versions", ["hashed_password"], :name => "index_person_versions_on_hashed_password", :unique => true
  add_index "person_versions", ["rotex_email"], :name => "index_person_versions_on_rotex_email", :unique => true

  create_table "promotions", :force => true do |t|
    t.column "name",             :string,                     :null => false
    t.column "is_outbound",      :boolean,  :default => true, :null => false
    t.column "comes_from_north", :boolean,  :default => true, :null => false
    t.column "created_at",       :datetime,                   :null => false
    t.column "updated_at",       :datetime,                   :null => false
    t.column "lock_version",     :integer,  :default => 0,    :null => false
  end

  add_index "promotions", ["name"], :name => "index_promotions_on_name", :unique => true

  create_table "roles", :force => true do |t|
    t.column "name",              :string,                     :null => false
    t.column "restriction_level", :integer,  :default => 1000, :null => false
    t.column "created_at",        :datetime,                   :null => false
    t.column "updated_at",        :datetime,                   :null => false
    t.column "lock_version",      :integer,  :default => 0,    :null => false
  end

  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "zone_natures", :force => true do |t|
    t.column "name",         :string,                  :null => false
    t.column "parent_id",    :integer
    t.column "created_at",   :datetime,                :null => false
    t.column "updated_at",   :datetime,                :null => false
    t.column "lock_version", :integer,  :default => 0, :null => false
  end

  add_index "zone_natures", ["name"], :name => "index_zone_natures_on_name", :unique => true

  create_table "zones", :force => true do |t|
    t.column "name",         :string,                  :null => false
    t.column "number",       :integer,                 :null => false
    t.column "code",         :text,                    :null => false
    t.column "nature_id",    :integer
    t.column "parent_id",    :integer
    t.column "country_id",   :integer
    t.column "created_at",   :datetime,                :null => false
    t.column "updated_at",   :datetime,                :null => false
    t.column "lock_version", :integer,  :default => 0, :null => false
  end

  add_index "zones", ["name"], :name => "index_zones_on_name", :unique => true
  add_index "zones", ["number", "parent_id"], :name => "index_zones_on_number_and_parent_id", :unique => true

  add_foreign_key "articles", ["language_id"], "languages", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "articles_language_id_fkey"
  add_foreign_key "articles", ["author_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "articles_author_id_fkey"
  add_foreign_key "articles", ["nature_id"], "article_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "articles_nature_id_fkey"

  add_foreign_key "countries", ["language_id"], "languages", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "countries_language_id_fkey"

  add_foreign_key "emails", ["from_person_id"], "people", ["id"], :name => "emails_from_person_id_fkey"

  add_foreign_key "families_people", ["family_id"], "families", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "families_people_family_id_fkey"
  add_foreign_key "families_people", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "families_people_person_id_fkey"

  add_foreign_key "folders", ["departure_person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_departure_person_id_fkey"
  add_foreign_key "folders", ["arrival_person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_arrival_person_id_fkey"
  add_foreign_key "folders", ["proposer_zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_proposer_zone_id_fkey"
  add_foreign_key "folders", ["sponsor_zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_sponsor_zone_id_fkey"
  add_foreign_key "folders", ["host_zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_host_zone_id_fkey"
  add_foreign_key "folders", ["promotion_id"], "promotions", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_promotion_id_fkey"
  add_foreign_key "folders", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_person_id_fkey"
  add_foreign_key "folders", ["arrival_country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_arrival_country_id_fkey"
  add_foreign_key "folders", ["departure_country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_departure_country_id_fkey"

  add_foreign_key "mandate_natures", ["parent_id"], "mandate_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandate_natures_parent_id_fkey"

  add_foreign_key "mandates", ["zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_zone_id_fkey"
  add_foreign_key "mandates", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_person_id_fkey"
  add_foreign_key "mandates", ["nature_id"], "mandate_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_nature_id_fkey"

  add_foreign_key "people", ["role_id"], "roles", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "people_role_id_fkey"
  add_foreign_key "people", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "people_country_id_fkey"

  add_foreign_key "periods", ["family_id"], "families", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "periods_family_id_fkey"
  add_foreign_key "periods", ["folder_id"], "folders", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "periods_folder_id_fkey"

  add_foreign_key "person_versions", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "person_versions_person_id_fkey"
  add_foreign_key "person_versions", ["role_id"], "roles", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "person_versions_role_id_fkey"
  add_foreign_key "person_versions", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "person_versions_country_id_fkey"

  add_foreign_key "zone_natures", ["parent_id"], "zone_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zone_natures_parent_id_fkey"

  add_foreign_key "zones", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_country_id_fkey"
  add_foreign_key "zones", ["parent_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_parent_id_fkey"
  add_foreign_key "zones", ["nature_id"], "zone_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_nature_id_fkey"

end
