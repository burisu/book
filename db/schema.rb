# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 3) do

  create_table "article_natures", :force => true do |t|
    t.string   "name",                                     :null => false
    t.string   "code",         :limit => 8,                :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "lock_version",              :default => 0, :null => false
  end

  create_table "articles", :force => true do |t|
    t.string   "title",                                      :null => false
    t.string   "intro",                                      :null => false
    t.text     "content",                                    :null => false
    t.string   "summary",      :limit => 512
    t.text     "html_intro"
    t.text     "html_content"
    t.text     "html_summary"
    t.integer  "nature_id",                                  :null => false
    t.integer  "author_id",                                  :null => false
    t.integer  "language_id",                                :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "lock_version",                :default => 0, :null => false
  end

  create_table "countries", :force => true do |t|
    t.string   "name",                                     :null => false
    t.string   "native_name"
    t.string   "iso3166",      :limit => 2,                :null => false
    t.integer  "language_id",                              :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "lock_version",              :default => 0, :null => false
  end

  add_index "countries", ["iso3166"], :name => "index_countries_on_iso3166", :unique => true
  add_index "countries", ["name"], :name => "index_countries_on_name", :unique => true

  create_table "emails", :force => true do |t|
    t.datetime "arrived_at",                        :null => false
    t.date     "sent_on",                           :null => false
    t.string   "subject",                           :null => false
    t.boolean  "unvalid",        :default => false, :null => false
    t.text     "from",                              :null => false
    t.boolean  "from_valid",     :default => false, :null => false
    t.integer  "from_person_id"
    t.text     "identifier",                        :null => false
    t.text     "to"
    t.text     "cc"
    t.text     "bcc"
    t.boolean  "manual_sent",    :default => false, :null => false
    t.datetime "sent_at"
    t.text     "message"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "lock_version",   :default => 0,     :null => false
  end

  add_index "emails", ["identifier"], :name => "index_emails_on_identifier"

  create_table "families", :force => true do |t|
    t.integer  "code",                        :null => false
    t.text     "comment"
    t.string   "photo"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "families", ["code"], :name => "index_families_on_code", :unique => true

  create_table "families_people", :force => true do |t|
    t.integer  "person_id",                   :null => false
    t.integer  "family_id",                   :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "folders", :force => true do |t|
    t.string   "name",                                :null => false
    t.integer  "departure_country_id",                :null => false
    t.integer  "arrival_country_id",                  :null => false
    t.integer  "person_id",                           :null => false
    t.integer  "promotion_id",                        :null => false
    t.integer  "host_zone_id",                        :null => false
    t.integer  "sponsor_zone_id",                     :null => false
    t.integer  "proposer_zone_id",                    :null => false
    t.integer  "arrival_person_id",                   :null => false
    t.integer  "departure_person_id",                 :null => false
    t.date     "begun_on",                            :null => false
    t.date     "finished_on",                         :null => false
    t.text     "comment"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "lock_version",         :default => 0, :null => false
  end

  add_index "folders", ["name"], :name => "index_folders_on_name", :unique => true

  create_table "languages", :force => true do |t|
    t.string   "name",                                     :null => false
    t.string   "native_name"
    t.string   "iso639",       :limit => 2,                :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "lock_version",              :default => 0, :null => false
  end

  create_table "mandate_natures", :force => true do |t|
    t.string   "name",                                     :null => false
    t.string   "code",         :limit => 4,                :null => false
    t.integer  "parent_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "lock_version",              :default => 0, :null => false
  end

  add_index "mandate_natures", ["code"], :name => "index_mandate_natures_on_code", :unique => true
  add_index "mandate_natures", ["name"], :name => "index_mandate_natures_on_name", :unique => true

  create_table "mandates", :force => true do |t|
    t.date     "begun_on",                    :null => false
    t.date     "finished_on"
    t.integer  "nature_id",                   :null => false
    t.integer  "person_id",                   :null => false
    t.integer  "zone_id",                     :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "patronymic_name",                                   :null => false
    t.string   "family_name"
    t.string   "first_name",                                        :null => false
    t.string   "second_name"
    t.boolean  "system",                         :default => false, :null => false
    t.boolean  "is_female",                      :default => true,  :null => false
    t.date     "born_on",                                           :null => false
    t.text     "home_address",                                      :null => false
    t.boolean  "aligned_to_right",               :default => false, :null => false
    t.string   "home_phone",       :limit => 32
    t.string   "work_phone",       :limit => 32
    t.string   "fax",              :limit => 32
    t.string   "mobile",           :limit => 32
    t.string   "messenger_email"
    t.string   "user_name",        :limit => 32,                    :null => false
    t.string   "email",                                             :null => false
    t.string   "hashed_password",                                   :null => false
    t.string   "salt",                                              :null => false
    t.string   "rotex_email"
    t.boolean  "is_locked",                      :default => false, :null => false
    t.string   "photo"
    t.integer  "country_id",                                        :null => false
    t.integer  "role_id",                                           :null => false
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "lock_version",                   :default => 0,     :null => false
  end

  add_index "people", ["hashed_password"], :name => "index_people_on_hashed_password", :unique => true
  add_index "people", ["rotex_email"], :name => "index_people_on_rotex_email", :unique => true
  add_index "people", ["user_name"], :name => "index_people_on_user_name", :unique => true

  create_table "periods", :force => true do |t|
    t.date     "begun_on",                    :null => false
    t.date     "finished_on",                 :null => false
    t.integer  "folder_id",                   :null => false
    t.integer  "family_id",                   :null => false
    t.text     "comment"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "person_versions", :force => true do |t|
    t.string   "patronymic_name",                                   :null => false
    t.string   "family_name"
    t.string   "first_name",                                        :null => false
    t.string   "second_name"
    t.boolean  "is_female",                      :default => true,  :null => false
    t.date     "born_on",                                           :null => false
    t.text     "home_address",                                      :null => false
    t.boolean  "aligned_to_right",               :default => false, :null => false
    t.string   "home_phone",       :limit => 32
    t.string   "work_phone",       :limit => 32
    t.string   "fax",              :limit => 32
    t.string   "mobile",           :limit => 32
    t.string   "messenger_email"
    t.string   "user_name",        :limit => 32,                    :null => false
    t.string   "email",                                             :null => false
    t.string   "hashed_password",                                   :null => false
    t.string   "salt",                                              :null => false
    t.string   "rotex_email"
    t.boolean  "is_locked",                      :default => false, :null => false
    t.string   "photo"
    t.integer  "country_id",                                        :null => false
    t.integer  "role_id",                                           :null => false
    t.integer  "person_id",                                         :null => false
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "lock_version",                   :default => 0,     :null => false
  end

  add_index "person_versions", ["hashed_password"], :name => "index_person_versions_on_hashed_password", :unique => true
  add_index "person_versions", ["rotex_email"], :name => "index_person_versions_on_rotex_email", :unique => true

  create_table "promotions", :force => true do |t|
    t.string   "name",                               :null => false
    t.boolean  "is_outbound",      :default => true, :null => false
    t.boolean  "comes_from_north", :default => true, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "lock_version",     :default => 0,    :null => false
  end

  add_index "promotions", ["name"], :name => "index_promotions_on_name", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "name",                                :null => false
    t.integer  "restriction_level", :default => 1000, :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "lock_version",      :default => 0,    :null => false
  end

  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",          :limit => 40
    t.string   "value",        :limit => 6
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "lock_version",               :default => 0, :null => false
  end

  create_table "zone_natures", :force => true do |t|
    t.string   "name",                        :null => false
    t.integer  "parent_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "zone_natures", ["name"], :name => "index_zone_natures_on_name", :unique => true

  create_table "zones", :force => true do |t|
    t.string   "name",                        :null => false
    t.integer  "number",                      :null => false
    t.text     "code",                        :null => false
    t.integer  "nature_id"
    t.integer  "parent_id"
    t.integer  "country_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "zones", ["name"], :name => "index_zones_on_name", :unique => true
  add_index "zones", ["number", "parent_id"], :name => "index_zones_on_number_and_parent_id", :unique => true

  add_foreign_key "articles", ["nature_id"], "article_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "articles_nature_id_fkey"
  add_foreign_key "articles", ["author_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "articles_author_id_fkey"
  add_foreign_key "articles", ["language_id"], "languages", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "articles_language_id_fkey"

  add_foreign_key "countries", ["language_id"], "languages", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "countries_language_id_fkey"

  add_foreign_key "emails", ["from_person_id"], "people", ["id"], :name => "emails_from_person_id_fkey"

  add_foreign_key "families_people", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "families_people_person_id_fkey"
  add_foreign_key "families_people", ["family_id"], "families", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "families_people_family_id_fkey"

  add_foreign_key "folders", ["departure_country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_departure_country_id_fkey"
  add_foreign_key "folders", ["arrival_country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_arrival_country_id_fkey"
  add_foreign_key "folders", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_person_id_fkey"
  add_foreign_key "folders", ["promotion_id"], "promotions", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_promotion_id_fkey"
  add_foreign_key "folders", ["host_zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_host_zone_id_fkey"
  add_foreign_key "folders", ["sponsor_zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_sponsor_zone_id_fkey"
  add_foreign_key "folders", ["proposer_zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_proposer_zone_id_fkey"
  add_foreign_key "folders", ["arrival_person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_arrival_person_id_fkey"
  add_foreign_key "folders", ["departure_person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_departure_person_id_fkey"

  add_foreign_key "mandate_natures", ["parent_id"], "mandate_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandate_natures_parent_id_fkey"

  add_foreign_key "mandates", ["nature_id"], "mandate_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_nature_id_fkey"
  add_foreign_key "mandates", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_person_id_fkey"
  add_foreign_key "mandates", ["zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_zone_id_fkey"

  add_foreign_key "people", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "people_country_id_fkey"
  add_foreign_key "people", ["role_id"], "roles", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "people_role_id_fkey"

  add_foreign_key "periods", ["folder_id"], "folders", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "periods_folder_id_fkey"
  add_foreign_key "periods", ["family_id"], "families", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "periods_family_id_fkey"

  add_foreign_key "person_versions", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "person_versions_country_id_fkey"
  add_foreign_key "person_versions", ["role_id"], "roles", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "person_versions_role_id_fkey"
  add_foreign_key "person_versions", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "person_versions_person_id_fkey"

  add_foreign_key "zone_natures", ["parent_id"], "zone_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zone_natures_parent_id_fkey"

  add_foreign_key "zones", ["nature_id"], "zone_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_nature_id_fkey"
  add_foreign_key "zones", ["parent_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_parent_id_fkey"
  add_foreign_key "zones", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_country_id_fkey"

end
