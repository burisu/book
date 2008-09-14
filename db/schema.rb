# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080808080808) do

  create_table "articles", :force => true do |t|
    t.string   "title",                                        :null => false
    t.text     "title_h",                                      :null => false
    t.string   "intro",        :limit => 512,                  :null => false
    t.text     "intro_h",                                      :null => false
    t.text     "body",                                         :null => false
    t.text     "content_h",                                    :null => false
    t.date     "done_on"
    t.text     "natures"
    t.string   "status",                      :default => "W", :null => false
    t.string   "document"
    t.integer  "author_id",                                    :null => false
    t.integer  "language_id",                                  :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "lock_version",                :default => 0,   :null => false
  end

  add_index "articles", ["author_id"], :name => "index_articles_on_author_id"
  add_index "articles", ["status"], :name => "index_articles_on_status"

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
    t.string   "title",        :limit => 512,                :null => false
    t.integer  "country_id",                                 :null => false
    t.string   "name",                                       :null => false
    t.string   "address",                                    :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.text     "comment"
    t.string   "photo"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "lock_version",                :default => 0, :null => false
  end

  add_index "families", ["title"], :name => "index_families_on_title", :unique => true

  create_table "folders", :force => true do |t|
    t.integer  "person_id",                           :null => false
    t.integer  "departure_country_id",                :null => false
    t.integer  "arrival_country_id",                  :null => false
    t.integer  "promotion_id",                        :null => false
    t.date     "begun_on",                            :null => false
    t.date     "finished_on",                         :null => false
    t.integer  "host_zone_id"
    t.integer  "sponsor_zone_id"
    t.integer  "proposer_zone_id"
    t.integer  "departure_person_id"
    t.integer  "arrival_person_id"
    t.text     "comment"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "lock_version",         :default => 0, :null => false
  end

  add_index "folders", ["arrival_country_id"], :name => "index_folders_on_arrival_country_id"
  add_index "folders", ["begun_on"], :name => "index_folders_on_begun_on"
  add_index "folders", ["departure_country_id"], :name => "index_folders_on_departure_country_id"
  add_index "folders", ["finished_on"], :name => "index_folders_on_finished_on"
  add_index "folders", ["person_id"], :name => "index_folders_on_person_id"
  add_index "folders", ["promotion_id"], :name => "index_folders_on_promotion_id"

  create_table "images", :force => true do |t|
    t.string   "title",                       :null => false
    t.text     "title_h",                     :null => false
    t.string   "desc"
    t.text     "desc_h"
    t.string   "document",                    :null => false
    t.integer  "person_id",                   :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "languages", :force => true do |t|
    t.string   "name",                                     :null => false
    t.string   "native_name"
    t.string   "iso639",       :limit => 2,                :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "lock_version",              :default => 0, :null => false
  end

  create_table "mandate_natures", :force => true do |t|
    t.string   "name",                                       :null => false
    t.string   "code",           :limit => 4,                :null => false
    t.integer  "zone_nature_id"
    t.integer  "parent_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "lock_version",                :default => 0, :null => false
  end

  add_index "mandate_natures", ["code"], :name => "index_mandate_natures_on_code", :unique => true
  add_index "mandate_natures", ["name"], :name => "index_mandate_natures_on_name", :unique => true

  create_table "mandates", :force => true do |t|
    t.boolean  "dont_expire",  :default => false, :null => false
    t.date     "begun_on",                        :null => false
    t.date     "finished_on"
    t.integer  "nature_id",                       :null => false
    t.integer  "person_id",                       :null => false
    t.integer  "zone_id",                         :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "lock_version", :default => 0,     :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "patronymic_name",                                    :null => false
    t.string   "family_name",                                        :null => false
    t.integer  "family_id"
    t.string   "first_name",                                         :null => false
    t.string   "second_name"
    t.string   "user_name",         :limit => 32,                    :null => false
    t.string   "photo"
    t.integer  "country_id",                                         :null => false
    t.string   "sex",               :limit => 1,                     :null => false
    t.date     "born_on",                                            :null => false
    t.text     "address",                                            :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "phone",             :limit => 32
    t.string   "phone2",            :limit => 32
    t.string   "fax",               :limit => 32
    t.string   "mobile",            :limit => 32
    t.string   "email",                                              :null => false
    t.string   "replacement_email"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "rotex_email"
    t.string   "validation"
    t.boolean  "is_validated",                    :default => false, :null => false
    t.boolean  "is_locked",                       :default => false, :null => false
    t.boolean  "is_user",                         :default => false, :null => false
    t.integer  "role_id",                                            :null => false
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.integer  "lock_version",                    :default => 0,     :null => false
  end

  add_index "people", ["is_user"], :name => "index_people_on_is_user"
  add_index "people", ["is_validated"], :name => "index_people_on_is_validated"
  add_index "people", ["role_id"], :name => "index_people_on_role_id"
  add_index "people", ["rotex_email"], :name => "index_people_on_rotex_email", :unique => true
  add_index "people", ["user_name"], :name => "index_people_on_user_name", :unique => true
  add_index "people", ["validation"], :name => "index_people_on_validation", :unique => true

  create_table "periods", :force => true do |t|
    t.date     "begun_on",                    :null => false
    t.date     "finished_on",                 :null => false
    t.integer  "person_id",                   :null => false
    t.integer  "folder_id",                   :null => false
    t.integer  "family_id",                   :null => false
    t.text     "comment"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "promotions", :force => true do |t|
    t.string   "name",                           :null => false
    t.boolean  "is_outbound",  :default => true, :null => false
    t.string   "from_code",    :default => "N",  :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "lock_version", :default => 0,    :null => false
  end

  add_index "promotions", ["name"], :name => "index_promotions_on_name", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "name",                        :null => false
    t.string   "code",                        :null => false
    t.text     "rights"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "roles", ["code"], :name => "index_roles_on_code", :unique => true
  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true
  add_index "roles", ["rights"], :name => "index_roles_on_rights"

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

  create_table "subscriptions", :force => true do |t|
    t.date     "begun_on",                                                   :null => false
    t.date     "finished_on",                                                :null => false
    t.decimal  "amount",       :precision => 16, :scale => 2,                :null => false
    t.string   "payment_mode",                                               :null => false
    t.text     "note"
    t.integer  "person_id",                                                  :null => false
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.integer  "lock_version",                                :default => 0, :null => false
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

  add_foreign_key "articles", ["author_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "articles_author_id_fkey"
  add_foreign_key "articles", ["language_id"], "languages", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "articles_language_id_fkey"

  add_foreign_key "countries", ["language_id"], "languages", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "countries_language_id_fkey"

  add_foreign_key "emails", ["from_person_id"], "people", ["id"], :name => "emails_from_person_id_fkey"

  add_foreign_key "families", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "families_country_id_fkey"

  add_foreign_key "folders", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_person_id_fkey"
  add_foreign_key "folders", ["departure_country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_departure_country_id_fkey"
  add_foreign_key "folders", ["arrival_country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_arrival_country_id_fkey"
  add_foreign_key "folders", ["promotion_id"], "promotions", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_promotion_id_fkey"
  add_foreign_key "folders", ["host_zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_host_zone_id_fkey"
  add_foreign_key "folders", ["sponsor_zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_sponsor_zone_id_fkey"
  add_foreign_key "folders", ["proposer_zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_proposer_zone_id_fkey"
  add_foreign_key "folders", ["departure_person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_departure_person_id_fkey"
  add_foreign_key "folders", ["arrival_person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "folders_arrival_person_id_fkey"

  add_foreign_key "images", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "images_person_id_fkey"

  add_foreign_key "mandate_natures", ["zone_nature_id"], "zone_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandate_natures_zone_nature_id_fkey"
  add_foreign_key "mandate_natures", ["parent_id"], "mandate_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandate_natures_parent_id_fkey"

  add_foreign_key "mandates", ["nature_id"], "mandate_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_nature_id_fkey"
  add_foreign_key "mandates", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_person_id_fkey"
  add_foreign_key "mandates", ["zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_zone_id_fkey"

  add_foreign_key "people", ["family_id"], "families", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "people_family_id_fkey"
  add_foreign_key "people", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "people_country_id_fkey"
  add_foreign_key "people", ["role_id"], "roles", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "people_role_id_fkey"

  add_foreign_key "periods", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "periods_person_id_fkey"
  add_foreign_key "periods", ["folder_id"], "folders", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "periods_folder_id_fkey"
  add_foreign_key "periods", ["family_id"], "families", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "periods_family_id_fkey"

  add_foreign_key "subscriptions", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "subscriptions_person_id_fkey"

  add_foreign_key "zone_natures", ["parent_id"], "zone_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zone_natures_parent_id_fkey"

  add_foreign_key "zones", ["nature_id"], "zone_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_nature_id_fkey"
  add_foreign_key "zones", ["parent_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_parent_id_fkey"
  add_foreign_key "zones", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_country_id_fkey"

end
