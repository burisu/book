# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120414074244) do

  create_table "activities", :force => true do |t|
    t.integer  "sector_id",                   :null => false
    t.string   "label"
    t.string   "name"
    t.string   "code"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "activities", ["sector_id"], :name => "index_activities_on_sector_id"

  create_table "activities_organigrams", :id => false, :force => true do |t|
    t.integer "activity_id",   :null => false
    t.integer "organigram_id", :null => false
  end

  add_index "activities_organigrams", ["activity_id"], :name => "index_activities_organigrams_on_activity_id"
  add_index "activities_organigrams", ["organigram_id"], :name => "index_activities_organigrams_on_organigram_id"

  create_table "answer_items", :force => true do |t|
    t.text     "content"
    t.integer  "answer_id",                       :null => false
    t.integer  "question_item_id",                :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "lock_version",     :default => 0, :null => false
  end

  add_index "answer_items", ["answer_id"], :name => "index_answer_items_on_answer_id"
  add_index "answer_items", ["question_item_id"], :name => "index_answer_items_on_question_id"

  create_table "answers", :force => true do |t|
    t.date     "created_on"
    t.boolean  "ready",        :default => false, :null => false
    t.boolean  "locked",       :default => false, :null => false
    t.integer  "person_id",                       :null => false
    t.integer  "question_id",                     :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "lock_version", :default => 0,     :null => false
  end

  add_index "answers", ["person_id"], :name => "index_answers_on_person_id"
  add_index "answers", ["question_id"], :name => "index_answers_on_questionnaire_id"

  create_table "articles", :force => true do |t|
    t.string   "title",                                        :null => false
    t.string   "intro",        :limit => 512,                  :null => false
    t.text     "body",                                         :null => false
    t.date     "done_on"
    t.text     "bad_natures"
    t.string   "status",                      :default => "W", :null => false
    t.string   "document"
    t.integer  "author_id",                                    :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "lock_version",                :default => 0,   :null => false
    t.integer  "rubric_id"
    t.string   "language",     :limit => 2
  end

  add_index "articles", ["author_id"], :name => "index_articles_on_author_id"
  add_index "articles", ["language"], :name => "index_articles_on_language"
  add_index "articles", ["status"], :name => "index_articles_on_status"

  create_table "articles_mandate_natures", :id => false, :force => true do |t|
    t.integer  "article_id"
    t.integer  "mandate_nature_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",      :default => 0
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "configurations", :force => true do |t|
    t.integer  "contact_article_id"
    t.integer  "about_article_id"
    t.integer  "legals_article_id"
    t.integer  "home_rubric_id"
    t.integer  "news_rubric_id"
    t.integer  "agenda_rubric_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                        :default => 0
    t.decimal  "subscription_price",                  :default => 0.0, :null => false
    t.text     "store_introduction"
    t.integer  "help_article_id"
    t.string   "chasing_up_days"
    t.text     "chasing_up_letter_before_expiration"
    t.text     "chasing_up_letter_after_expiration"
  end

  create_table "event_natures", :force => true do |t|
    t.string   "name"
    t.text     "comment"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "place"
    t.text     "description"
    t.text     "comment"
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
    t.integer  "nature_id",                   :null => false
  end

  create_table "extra_emails", :id => false, :force => true do |t|
    t.string "email_liste"
    t.string "email"
  end

  create_table "group_intervention_natures", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "comment"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "group_interventions", :force => true do |t|
    t.integer  "nature_id"
    t.integer  "group_id"
    t.integer  "event_id"
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.text     "description"
    t.text     "comment"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "group_interventions", ["event_id"], :name => "index_group_interventions_on_event_id"
  add_index "group_interventions", ["group_id"], :name => "index_group_interventions_on_group_id"
  add_index "group_interventions", ["nature_id"], :name => "index_group_interventions_on_nature_id"

  create_table "group_kinships", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.integer  "organization_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "lock_version",    :default => 0, :null => false
  end

  add_index "group_kinships", ["child_id"], :name => "index_group_kinships_on_children_id"
  add_index "group_kinships", ["organization_id"], :name => "index_group_kinships_on_organization_id"
  add_index "group_kinships", ["parent_id"], :name => "index_group_kinships_on_parent_id"

  create_table "group_natures", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.integer  "zone_nature_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "lock_version",    :default => 0, :null => false
  end

  add_index "group_natures", ["organization_id"], :name => "index_group_natures_on_organization_id"
  add_index "group_natures", ["zone_nature_id"], :name => "index_group_natures_on_zone_nature_id"

  create_table "group_natures_groups", :id => false, :force => true do |t|
    t.integer  "group_nature_id"
    t.integer  "group_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "lock_version",    :default => 0, :null => false
  end

  add_index "group_natures_groups", ["group_id"], :name => "index_group_natures_groups_on_group_id"
  add_index "group_natures_groups", ["group_nature_id"], :name => "index_group_natures_groups_on_group_nature_id"

  create_table "groups", :force => true do |t|
    t.string   "name",                                       :null => false
    t.integer  "number",                                     :null => false
    t.text     "code",                                       :null => false
    t.integer  "zone_nature_id"
    t.integer  "parent_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "lock_version",                :default => 0, :null => false
    t.string   "country",        :limit => 2
  end

  add_index "groups", ["country"], :name => "index_groups_on_country"
  add_index "groups", ["name", "parent_id"], :name => "index_zones_on_name_and_parent_id"
  add_index "groups", ["number", "parent_id"], :name => "index_zones_on_number_and_parent_id", :unique => true

  create_table "guests", :force => true do |t|
    t.integer  "sale_line_id"
    t.integer  "sale_id"
    t.integer  "product_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "zone_id"
    t.text     "annotation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  add_index "guests", ["product_id"], :name => "index_guests_on_product_id"
  add_index "guests", ["sale_id"], :name => "index_guests_on_sale_id"
  add_index "guests", ["sale_line_id"], :name => "index_guests_on_sale_line_id"
  add_index "guests", ["zone_id"], :name => "index_guests_on_zone_id"

  create_table "honour_natures", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "comment"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "honours", :force => true do |t|
    t.integer  "nature_id"
    t.string   "name"
    t.string   "abbreviation"
    t.integer  "position"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "honours", ["nature_id"], :name => "index_honours_on_nature_id"

  create_table "images", :force => true do |t|
    t.string   "title",                                    :null => false
    t.text     "title_h",                                  :null => false
    t.string   "desc"
    t.text     "desc_h"
    t.string   "document_file_name",                       :null => false
    t.integer  "person_id",                                :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "lock_version",          :default => 0,     :null => false
    t.string   "name",                                     :null => false
    t.boolean  "locked",                :default => false, :null => false
    t.boolean  "deleted",               :default => false, :null => false
    t.boolean  "published",             :default => true,  :null => false
    t.integer  "document_file_size"
    t.string   "document_content_type"
    t.datetime "document_updated_at"
  end

  create_table "mandate_natures", :force => true do |t|
    t.string   "name",                           :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "lock_version",    :default => 0, :null => false
    t.text     "rights"
    t.integer  "group_nature_id"
  end

  add_index "mandate_natures", ["name"], :name => "index_mandate_natures_on_name", :unique => true

  create_table "mandates", :force => true do |t|
    t.boolean  "dont_expire",  :default => false, :null => false
    t.date     "started_on",                      :null => false
    t.date     "stopped_on"
    t.integer  "nature_id",                       :null => false
    t.integer  "person_id",                       :null => false
    t.integer  "group_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "lock_version", :default => 0,     :null => false
  end

  create_table "members", :force => true do |t|
    t.string   "last_name",                                 :null => false
    t.string   "first_name",                                :null => false
    t.string   "photo"
    t.string   "nature",       :limit => 8,                 :null => false
    t.string   "other_nature"
    t.string   "sex",          :limit => 1,                 :null => false
    t.string   "phone",        :limit => 32
    t.string   "fax",          :limit => 32
    t.string   "mobile",       :limit => 32
    t.text     "comment"
    t.integer  "person_id",                                 :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "lock_version",               :default => 0, :null => false
    t.string   "email"
  end

  add_index "members", ["person_id"], :name => "index_members_on_person_id"

  create_table "members_periods", :id => false, :force => true do |t|
    t.integer  "member_id",                   :null => false
    t.integer  "period_id",                   :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "members_periods", ["member_id", "period_id"], :name => "index_members_periods_on_member_id_and_period_id", :unique => true
  add_index "members_periods", ["member_id"], :name => "index_members_periods_on_member_id"
  add_index "members_periods", ["period_id"], :name => "index_members_periods_on_period_id"

  create_table "organigram_professions", :force => true do |t|
    t.integer  "organigram_id"
    t.string   "name"
    t.boolean  "printed",       :default => false, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "lock_version",  :default => 0,     :null => false
  end

  add_index "organigram_professions", ["organigram_id"], :name => "index_organigram_professions_on_organigram_id"

  create_table "organigrams", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.text     "description"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "comment"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "patronymic_name",                                      :null => false
    t.string   "family_name",                                          :null => false
    t.integer  "family_id"
    t.string   "first_name",                                           :null => false
    t.string   "second_name"
    t.string   "user_name",           :limit => 32,                    :null => false
    t.string   "photo_file_name"
    t.string   "sex",                 :limit => 1,                     :null => false
    t.date     "born_on",                                              :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "email",                                                :null => false
    t.string   "replacement_email"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "rotex_email"
    t.string   "validation"
    t.boolean  "is_validated",                      :default => false, :null => false
    t.boolean  "is_locked",                         :default => false, :null => false
    t.boolean  "is_user",                           :default => false, :null => false
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.integer  "lock_version",                      :default => 0,     :null => false
    t.boolean  "student",                           :default => false, :null => false
    t.integer  "arrival_person_id"
    t.date     "started_on"
    t.date     "stopped_on"
    t.text     "comment"
    t.integer  "departure_person_id"
    t.integer  "host_zone_id"
    t.integer  "promotion_id"
    t.integer  "proposer_zone_id"
    t.integer  "sponsor_zone_id"
    t.boolean  "approved",                          :default => false, :null => false
    t.string   "language",            :limit => 2
    t.string   "birth_country",       :limit => 2
    t.string   "arrival_country",     :limit => 2
    t.string   "departure_country",   :limit => 2
    t.integer  "photo_file_size"
    t.string   "photo_content_type"
    t.datetime "photo_updated_at"
    t.integer  "activity_id"
    t.integer  "profession_id"
  end

  add_index "people", ["arrival_country"], :name => "index_people_on_arrival_country"
  add_index "people", ["birth_country"], :name => "index_people_on_country"
  add_index "people", ["departure_country"], :name => "index_people_on_departure_country"
  add_index "people", ["host_zone_id"], :name => "index_people_on_host_zone_id"
  add_index "people", ["is_user"], :name => "index_people_on_is_user"
  add_index "people", ["is_validated"], :name => "index_people_on_is_validated"
  add_index "people", ["language"], :name => "index_people_on_language"
  add_index "people", ["promotion_id"], :name => "index_people_on_promotion_id"
  add_index "people", ["proposer_zone_id"], :name => "index_people_on_proposer_zone_id"
  add_index "people", ["rotex_email"], :name => "index_people_on_rotex_email", :unique => true
  add_index "people", ["sponsor_zone_id"], :name => "index_people_on_sponsor_zone_id"
  add_index "people", ["started_on"], :name => "index_people_on_started_on"
  add_index "people", ["stopped_on"], :name => "index_people_on_stopped_on"
  add_index "people", ["user_name"], :name => "index_people_on_user_name", :unique => true
  add_index "people", ["validation"], :name => "index_people_on_validation", :unique => true

  create_table "periods", :force => true do |t|
    t.date     "begun_on",                                  :null => false
    t.date     "finished_on",                               :null => false
    t.integer  "person_id",                                 :null => false
    t.text     "comment"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "lock_version",               :default => 0, :null => false
    t.string   "family_name",                               :null => false
    t.string   "address",                                   :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "photo"
    t.string   "phone",        :limit => 32
    t.string   "fax",          :limit => 32
    t.string   "email",        :limit => 32
    t.string   "mobile",       :limit => 32
    t.string   "country",      :limit => 2
  end

  add_index "periods", ["country"], :name => "index_periods_on_country"

  create_table "person_contact_natures", :force => true do |t|
    t.string   "name",                        :null => false
    t.string   "canal",                       :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "person_contact_natures", ["canal"], :name => "index_person_contact_natures_on_canal"

  create_table "person_contacts", :force => true do |t|
    t.integer  "person_id",                       :null => false
    t.integer  "nature_id",                       :null => false
    t.string   "canal",                           :null => false
    t.string   "address",                         :null => false
    t.string   "line_2"
    t.string   "line_3"
    t.string   "line_4"
    t.string   "line_5"
    t.string   "line_6"
    t.string   "postcode"
    t.string   "city"
    t.string   "country"
    t.boolean  "receiving",    :default => false, :null => false
    t.boolean  "sending",      :default => false, :null => false
    t.boolean  "by_default",   :default => false, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "lock_version", :default => 0,     :null => false
  end

  add_index "person_contacts", ["canal"], :name => "index_person_contacts_on_canal"
  add_index "person_contacts", ["nature_id"], :name => "index_person_contacts_on_nature_id"
  add_index "person_contacts", ["person_id"], :name => "index_person_contacts_on_person_id"

  create_table "person_honours", :force => true do |t|
    t.integer  "person_id",                   :null => false
    t.integer  "honour_id",                   :null => false
    t.date     "given_on"
    t.text     "comment"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "person_honours", ["honour_id"], :name => "index_person_honours_on_honour_id"
  add_index "person_honours", ["person_id"], :name => "index_person_honours_on_person_id"

  create_table "person_intervention_natures", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "comment"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "person_interventions", :force => true do |t|
    t.integer  "nature_id"
    t.integer  "person_id"
    t.integer  "event_id"
    t.integer  "group_intervention_id"
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.text     "description"
    t.text     "comment"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "lock_version",          :default => 0, :null => false
  end

  add_index "person_interventions", ["event_id"], :name => "index_person_interventions_on_event_id"
  add_index "person_interventions", ["group_intervention_id"], :name => "index_person_interventions_on_group_intervention_id"
  add_index "person_interventions", ["nature_id"], :name => "index_person_interventions_on_nature_id"
  add_index "person_interventions", ["person_id"], :name => "index_person_interventions_on_person_id"

  create_table "products", :force => true do |t|
    t.string   "name",                                                                        :null => false
    t.text     "description"
    t.decimal  "amount",                 :precision => 16, :scale => 2, :default => 0.0,      :null => false
    t.string   "unit",                                                  :default => "unités", :null => false
    t.boolean  "deadlined",                                             :default => false,    :null => false
    t.date     "started_on"
    t.date     "stopped_on"
    t.boolean  "storable",                                              :default => false,    :null => false
    t.decimal  "initial_quantity",       :precision => 16, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "current_quantity",       :precision => 16, :scale => 2, :default => 0.0,      :null => false
    t.boolean  "subscribing",                                           :default => false,    :null => false
    t.date     "subscribing_started_on"
    t.date     "subscribing_stopped_on"
    t.boolean  "personal",                                              :default => false,    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                          :default => 0
    t.boolean  "active",                                                :default => false,    :null => false
    t.boolean  "passworded",                                            :default => false,    :null => false
    t.string   "password"
  end

  add_index "products", ["name"], :name => "index_products_on_name"

  create_table "promotions", :force => true do |t|
    t.string   "name",                           :null => false
    t.boolean  "is_outbound",  :default => true, :null => false
    t.string   "from_code",    :default => "N",  :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "lock_version", :default => 0,    :null => false
  end

  add_index "promotions", ["name"], :name => "index_promotions_on_name", :unique => true

  create_table "question_items", :force => true do |t|
    t.string   "name",                        :null => false
    t.text     "explanation"
    t.integer  "position"
    t.integer  "question_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
    t.integer  "theme_id"
  end

  add_index "question_items", ["question_id"], :name => "index_questions_on_questionnaire_id"

  create_table "questions", :force => true do |t|
    t.string   "name",         :limit => 64,                :null => false
    t.text     "intro"
    t.text     "comment"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "lock_version",               :default => 0, :null => false
    t.date     "started_on"
    t.date     "stopped_on"
    t.integer  "promotion_id"
  end

  add_index "questions", ["name"], :name => "index_questionnaires_on_name", :unique => true
  add_index "questions", ["started_on"], :name => "index_questionnaires_on_started_on"
  add_index "questions", ["stopped_on"], :name => "index_questionnaires_on_stopped_on"

  create_table "redirection_virtuals", :id => false, :force => true do |t|
    t.string "virtual_email"
    t.string "email"
  end

  create_table "rubrics", :force => true do |t|
    t.string   "name",                         :null => false
    t.string   "code",                         :null => false
    t.string   "logo"
    t.text     "description"
    t.integer  "parent_id"
    t.integer  "rubrics_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",  :default => 0
  end

  add_index "rubrics", ["parent_id"], :name => "index_rubrics_on_parent_id"

  create_table "sale_lines", :force => true do |t|
    t.integer  "sale_id",                                                      :null => false
    t.integer  "product_id",                                                   :null => false
    t.string   "name",                                                         :null => false
    t.text     "description"
    t.decimal  "unit_amount",  :precision => 16, :scale => 2, :default => 0.0, :null => false
    t.decimal  "quantity",     :precision => 16, :scale => 2, :default => 0.0, :null => false
    t.decimal  "amount",       :precision => 16, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                :default => 0
  end

  add_index "sale_lines", ["product_id"], :name => "index_sale_lines_on_product_id"
  add_index "sale_lines", ["sale_id"], :name => "index_sale_lines_on_sale_id"

  create_table "sales", :force => true do |t|
    t.string   "number",                                                                  :null => false
    t.string   "state",                                                                   :null => false
    t.text     "comment"
    t.integer  "client_id"
    t.string   "client_email",                                                            :null => false
    t.decimal  "amount",               :precision => 16, :scale => 2
    t.date     "created_on",                                                              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                        :default => 0
    t.string   "sequential_number"
    t.string   "authorization_number"
    t.string   "payment_type"
    t.string   "card_type"
    t.string   "transaction_number"
    t.string   "country"
    t.string   "error_code"
    t.date     "card_expired_on"
    t.string   "payer_country"
    t.string   "signature"
    t.string   "bin6"
    t.string   "payment_mode",                                        :default => "none", :null => false
    t.string   "payment_number"
  end

  add_index "sales", ["client_id"], :name => "index_sales_on_client_id"
  add_index "sales", ["created_on"], :name => "index_sales_on_created_on"
  add_index "sales", ["number"], :name => "index_sales_on_number"
  add_index "sales", ["payment_mode"], :name => "index_sales_on_payment_mode"

  create_table "sectors", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.text     "description"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "subscriptions", :force => true do |t|
    t.date     "begun_on",                                  :null => false
    t.date     "finished_on",                               :null => false
    t.integer  "person_id",                                 :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "lock_version",               :default => 0, :null => false
    t.string   "number",       :limit => 64
    t.integer  "sale_id"
    t.integer  "sale_line_id"
  end

  create_table "themes", :force => true do |t|
    t.string   "name",                                :null => false
    t.string   "color",        :default => "#808080", :null => false
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  create_table "zone_natures", :force => true do |t|
    t.string   "name",                        :null => false
    t.integer  "parent_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "zone_natures", ["name"], :name => "index_zone_natures_on_name", :unique => true

end
