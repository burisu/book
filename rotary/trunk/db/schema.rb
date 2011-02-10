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

ActiveRecord::Schema.define(:version => 20110206173531) do

  create_table "answer_items", :force => true do |t|
    t.text     "content"
    t.integer  "answer_id",                   :null => false
    t.integer  "question_id",                 :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "answer_items", ["answer_id"], :name => "index_answer_items_on_answer_id"
  add_index "answer_items", ["question_id"], :name => "index_answer_items_on_question_id"

  create_table "answers", :force => true do |t|
    t.date     "created_on"
    t.boolean  "ready",            :default => false, :null => false
    t.boolean  "locked",           :default => false, :null => false
    t.integer  "person_id",                           :null => false
    t.integer  "questionnaire_id",                    :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "lock_version",     :default => 0,     :null => false
  end

  add_index "answers", ["person_id"], :name => "index_answers_on_person_id"
  add_index "answers", ["questionnaire_id"], :name => "index_answers_on_questionnaire_id"

  create_table "articles", :force => true do |t|
    t.string   "title",                                        :null => false
    t.string   "intro",        :limit => 512,                  :null => false
    t.text     "body",                                         :null => false
    t.date     "done_on"
    t.text     "bad_natures"
    t.string   "status",                      :default => "W", :null => false
    t.string   "document"
    t.integer  "author_id",                                    :null => false
    t.integer  "language_id",                                  :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "lock_version",                :default => 0,   :null => false
    t.integer  "rubric_id"
  end

  add_index "articles", ["author_id"], :name => "index_articles_on_author_id"
  add_index "articles", ["status"], :name => "index_articles_on_status"

  create_table "articles_mandate_natures", :id => false, :force => true do |t|
    t.integer  "article_id"
    t.integer  "mandate_nature_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",      :default => 0
  end

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

  create_table "images", :force => true do |t|
    t.string   "title",                           :null => false
    t.text     "title_h",                         :null => false
    t.string   "desc"
    t.text     "desc_h"
    t.string   "document",                        :null => false
    t.integer  "person_id",                       :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "lock_version", :default => 0,     :null => false
    t.string   "name",                            :null => false
    t.boolean  "locked",       :default => false, :null => false
    t.boolean  "deleted",      :default => false, :null => false
    t.boolean  "published",    :default => true,  :null => false
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
    t.string   "code",           :limit => 8,                :null => false
    t.integer  "zone_nature_id"
    t.integer  "parent_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "lock_version",                :default => 0, :null => false
    t.text     "rights"
  end

  add_index "mandate_natures", ["code"], :name => "index_mandate_natures_on_code", :unique => true
  add_index "mandate_natures", ["name"], :name => "index_mandate_natures_on_name", :unique => true

  create_table "mandates", :force => true do |t|
    t.boolean  "dont_expire",  :default => false, :null => false
    t.date     "begun_on",                        :null => false
    t.date     "finished_on"
    t.integer  "nature_id",                       :null => false
    t.integer  "person_id",                       :null => false
    t.integer  "zone_id"
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

  add_index "members_periods", ["member_id"], :name => "index_members_periods_on_member_id"
  add_index "members_periods", ["member_id", "period_id"], :name => "index_members_periods_on_member_id_and_period_id", :unique => true
  add_index "members_periods", ["period_id"], :name => "index_members_periods_on_period_id"

  create_table "payments", :force => true do |t|
    t.decimal  "amount",                             :precision => 16, :scale => 2, :default => 0.0, :null => false
    t.decimal  "used_amount",                        :precision => 16, :scale => 2, :default => 0.0, :null => false
    t.integer  "payer_id"
    t.string   "payer_email",                                                                        :null => false
    t.string   "mode",                                                                               :null => false
    t.string   "number",               :limit => 16
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                                      :default => 0
  end

  add_index "payments", ["mode"], :name => "index_payments_on_mode"
  add_index "payments", ["number"], :name => "index_payments_on_number"
  add_index "payments", ["payer_id"], :name => "index_payments_on_payer_id"

  create_table "people", :force => true do |t|
    t.string   "patronymic_name",                                       :null => false
    t.string   "family_name",                                           :null => false
    t.integer  "family_id"
    t.string   "first_name",                                            :null => false
    t.string   "second_name"
    t.string   "user_name",            :limit => 32,                    :null => false
    t.string   "photo"
    t.integer  "country_id",                                            :null => false
    t.string   "sex",                  :limit => 1,                     :null => false
    t.date     "born_on",                                               :null => false
    t.text     "address",                                               :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "phone",                :limit => 32
    t.string   "phone2",               :limit => 32
    t.string   "fax",                  :limit => 32
    t.string   "mobile",               :limit => 32
    t.string   "email",                                                 :null => false
    t.string   "replacement_email"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "rotex_email"
    t.string   "validation"
    t.boolean  "is_validated",                       :default => false, :null => false
    t.boolean  "is_locked",                          :default => false, :null => false
    t.boolean  "is_user",                            :default => false, :null => false
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.integer  "lock_version",                       :default => 0,     :null => false
    t.boolean  "student",                            :default => false, :null => false
    t.integer  "arrival_country_id"
    t.integer  "arrival_person_id"
    t.date     "started_on"
    t.date     "stopped_on"
    t.text     "comment"
    t.integer  "departure_country_id"
    t.integer  "departure_person_id"
    t.integer  "host_zone_id"
    t.integer  "promotion_id"
    t.integer  "proposer_zone_id"
    t.integer  "sponsor_zone_id"
    t.boolean  "approved",                           :default => false, :null => false
  end

  add_index "people", ["arrival_country_id"], :name => "index_people_on_arrival_country_id"
  add_index "people", ["departure_country_id"], :name => "index_people_on_departure_country_id"
  add_index "people", ["host_zone_id"], :name => "index_people_on_host_zone_id"
  add_index "people", ["is_user"], :name => "index_people_on_is_user"
  add_index "people", ["is_validated"], :name => "index_people_on_is_validated"
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
    t.integer  "country_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "photo"
    t.string   "phone",        :limit => 32
    t.string   "fax",          :limit => 32
    t.string   "email",        :limit => 32
    t.string   "mobile",       :limit => 32
  end

  create_table "person_versions", :force => true do |t|
    t.integer  "person_id"
    t.string   "patronymic_name"
    t.string   "family_name"
    t.integer  "family_id"
    t.string   "first_name"
    t.string   "second_name"
    t.string   "user_name"
    t.string   "photo"
    t.integer  "country_id"
    t.string   "sex"
    t.date     "born_on"
    t.text     "address"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "phone"
    t.string   "phone2"
    t.string   "fax"
    t.string   "mobile"
    t.string   "email"
    t.string   "replacement_email"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "rotex_email"
    t.string   "validation"
    t.boolean  "is_validated"
    t.boolean  "is_locked"
    t.boolean  "is_user"
    t.integer  "role_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "lock_version",         :default => 0,     :null => false
    t.boolean  "student",              :default => false, :null => false
    t.integer  "arrival_country_id"
    t.integer  "arrival_person_id"
    t.date     "started_on"
    t.date     "stopped_on"
    t.text     "comment"
    t.integer  "departure_country_id"
    t.integer  "departure_person_id"
    t.integer  "host_zone_id"
    t.integer  "promotion_id"
    t.integer  "proposer_zone_id"
    t.integer  "sponsor_zone_id"
    t.boolean  "approved"
  end

  create_table "products", :force => true do |t|
    t.string   "name",                                                                         :null => false
    t.text     "description"
    t.decimal  "amount",                 :precision => 16, :scale => 2, :default => 0.0,       :null => false
    t.string   "unit",                                                  :default => "unités", :null => false
    t.boolean  "deadlined",                                             :default => false,     :null => false
    t.date     "started_on"
    t.date     "stopped_on"
    t.boolean  "storable",                                              :default => false,     :null => false
    t.decimal  "initial_quantity",       :precision => 16, :scale => 2, :default => 0.0,       :null => false
    t.decimal  "current_quantity",       :precision => 16, :scale => 2, :default => 0.0,       :null => false
    t.boolean  "subscribing",                                           :default => false,     :null => false
    t.date     "subscribing_started_on"
    t.date     "subscribing_stopped_on"
    t.boolean  "personal",                                              :default => false,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                          :default => 0
    t.boolean  "active",                                                :default => false,     :null => false
    t.boolean  "passworded",                                            :default => false,     :null => false
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

  create_table "questionnaires", :force => true do |t|
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

  add_index "questionnaires", ["name"], :name => "index_questionnaires_on_name", :unique => true
  add_index "questionnaires", ["started_on"], :name => "index_questionnaires_on_started_on"
  add_index "questionnaires", ["stopped_on"], :name => "index_questionnaires_on_stopped_on"

  create_table "questions", :force => true do |t|
    t.string   "name",                            :null => false
    t.text     "explanation"
    t.integer  "position"
    t.integer  "questionnaire_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "lock_version",     :default => 0, :null => false
    t.integer  "theme_id"
  end

  add_index "questions", ["questionnaire_id"], :name => "index_questions_on_questionnaire_id"

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
    t.string   "number",                                                     :null => false
    t.string   "state",                                                      :null => false
    t.text     "comment"
    t.integer  "client_id"
    t.string   "client_email",                                               :null => false
    t.decimal  "amount",       :precision => 16, :scale => 2
    t.date     "created_on",                                                 :null => false
    t.integer  "payment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                :default => 0
  end

  add_index "sales", ["client_id"], :name => "index_sales_on_client_id"
  add_index "sales", ["created_on"], :name => "index_sales_on_created_on"
  add_index "sales", ["number"], :name => "index_sales_on_number"
  add_index "sales", ["payment_id"], :name => "index_sales_on_payment_id"

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

  add_index "zones", ["name", "parent_id"], :name => "index_zones_on_name_and_parent_id"
  add_index "zones", ["number", "parent_id"], :name => "index_zones_on_number_and_parent_id", :unique => true

  add_foreign_key "answer_items", ["answer_id"], "answers", ["id"], :name => "answer_items_answer_id_fkey"
  add_foreign_key "answer_items", ["question_id"], "questions", ["id"], :name => "answer_items_question_id_fkey"

  add_foreign_key "answers", ["person_id"], "people", ["id"], :name => "answers_person_id_fkey"
  add_foreign_key "answers", ["questionnaire_id"], "questionnaires", ["id"], :name => "answers_questionnaire_id_fkey"

  add_foreign_key "articles", ["author_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "articles_author_id_fkey"
  add_foreign_key "articles", ["language_id"], "languages", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "articles_language_id_fkey"
  add_foreign_key "articles", ["rubric_id"], "rubrics", ["id"], :name => "articles_rubric_id_fkey"

  add_foreign_key "articles_mandate_natures", ["article_id"], "articles", ["id"], :name => "articles_mandate_natures_article_id_fkey"
  add_foreign_key "articles_mandate_natures", ["mandate_nature_id"], "mandate_natures", ["id"], :name => "articles_mandate_natures_mandate_nature_id_fkey"

  add_foreign_key "configurations", ["about_article_id"], "articles", ["id"], :name => "configurations_about_article_id_fkey"
  add_foreign_key "configurations", ["agenda_rubric_id"], "rubrics", ["id"], :name => "configurations_agenda_rubric_id_fkey"
  add_foreign_key "configurations", ["contact_article_id"], "articles", ["id"], :name => "configurations_contact_article_id_fkey"
  add_foreign_key "configurations", ["help_article_id"], "articles", ["id"], :name => "configurations_help_article_id_fkey"
  add_foreign_key "configurations", ["home_rubric_id"], "rubrics", ["id"], :name => "configurations_home_rubric_id_fkey"
  add_foreign_key "configurations", ["legals_article_id"], "articles", ["id"], :name => "configurations_legals_article_id_fkey"
  add_foreign_key "configurations", ["news_rubric_id"], "rubrics", ["id"], :name => "configurations_news_rubric_id_fkey"

  add_foreign_key "countries", ["language_id"], "languages", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "countries_language_id_fkey"

  add_foreign_key "emails", ["from_person_id"], "people", ["id"], :name => "emails_from_person_id_fkey"

  add_foreign_key "guests", ["sale_line_id"], "sale_lines", ["id"], :name => "guests_sale_line_id_fkey"
  add_foreign_key "guests", ["sale_id"], "sales", ["id"], :name => "guests_sale_id_fkey"
  add_foreign_key "guests", ["product_id"], "products", ["id"], :name => "guests_product_id_fkey"
  add_foreign_key "guests", ["zone_id"], "zones", ["id"], :name => "guests_zone_id_fkey"

  add_foreign_key "images", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "images_person_id_fkey"

  add_foreign_key "mandate_natures", ["parent_id"], "mandate_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandate_natures_parent_id_fkey"
  add_foreign_key "mandate_natures", ["zone_nature_id"], "zone_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandate_natures_zone_nature_id_fkey"

  add_foreign_key "mandates", ["nature_id"], "mandate_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_nature_id_fkey"
  add_foreign_key "mandates", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_person_id_fkey"
  add_foreign_key "mandates", ["zone_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "mandates_zone_id_fkey"

  add_foreign_key "members", ["person_id"], "people", ["id"], :name => "members_person_id_fkey"

  add_foreign_key "members_periods", ["member_id"], "members", ["id"], :name => "members_periods_member_id_fkey"
  add_foreign_key "members_periods", ["period_id"], "periods", ["id"], :name => "members_periods_period_id_fkey"

  add_foreign_key "payments", ["payer_id"], "people", ["id"], :name => "payments_payer_id_fkey"

  add_foreign_key "people", ["arrival_country_id"], "countries", ["id"], :name => "people_arrival_country_id_fkey"
  add_foreign_key "people", ["arrival_person_id"], "people", ["id"], :name => "people_arrival_person_id_fkey"
  add_foreign_key "people", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "people_country_id_fkey"
  add_foreign_key "people", ["departure_country_id"], "countries", ["id"], :name => "people_departure_country_id_fkey"
  add_foreign_key "people", ["departure_person_id"], "people", ["id"], :name => "people_departure_person_id_fkey"
  add_foreign_key "people", ["host_zone_id"], "zones", ["id"], :name => "people_host_zone_id_fkey"
  add_foreign_key "people", ["promotion_id"], "promotions", ["id"], :name => "people_promotion_id_fkey"
  add_foreign_key "people", ["proposer_zone_id"], "zones", ["id"], :name => "people_proposer_zone_id_fkey"
  add_foreign_key "people", ["sponsor_zone_id"], "zones", ["id"], :name => "people_sponsor_zone_id_fkey"

  add_foreign_key "periods", ["country_id"], "countries", ["id"], :name => "periods_country_id_fkey"
  add_foreign_key "periods", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "periods_person_id_fkey"

  add_foreign_key "person_versions", ["arrival_country_id"], "countries", ["id"], :name => "person_versions_arrival_country_id_fkey"
  add_foreign_key "person_versions", ["arrival_person_id"], "people", ["id"], :name => "person_versions_arrival_person_id_fkey"
  add_foreign_key "person_versions", ["departure_country_id"], "countries", ["id"], :name => "person_versions_departure_country_id_fkey"
  add_foreign_key "person_versions", ["departure_person_id"], "people", ["id"], :name => "person_versions_departure_person_id_fkey"
  add_foreign_key "person_versions", ["host_zone_id"], "zones", ["id"], :name => "person_versions_host_zone_id_fkey"
  add_foreign_key "person_versions", ["person_id"], "people", ["id"], :name => "person_versions_person_id_fkey"
  add_foreign_key "person_versions", ["promotion_id"], "promotions", ["id"], :name => "person_versions_promotion_id_fkey"
  add_foreign_key "person_versions", ["proposer_zone_id"], "zones", ["id"], :name => "person_versions_proposer_zone_id_fkey"
  add_foreign_key "person_versions", ["sponsor_zone_id"], "zones", ["id"], :name => "person_versions_sponsor_zone_id_fkey"

  add_foreign_key "questionnaires", ["promotion_id"], "promotions", ["id"], :name => "questionnaires_promotion_id_fkey"

  add_foreign_key "questions", ["questionnaire_id"], "questionnaires", ["id"], :name => "questions_questionnaire_id_fkey"
  add_foreign_key "questions", ["theme_id"], "themes", ["id"], :name => "questions_theme_id_fkey"

  add_foreign_key "rubrics", ["parent_id"], "rubrics", ["id"], :name => "rubrics_parent_id_fkey"

  add_foreign_key "sale_lines", ["sale_id"], "sales", ["id"], :name => "sale_lines_sale_id_fkey"
  add_foreign_key "sale_lines", ["product_id"], "products", ["id"], :name => "sale_lines_product_id_fkey"

  add_foreign_key "sales", ["client_id"], "people", ["id"], :name => "sales_client_id_fkey"
  add_foreign_key "sales", ["payment_id"], "payments", ["id"], :name => "sales_payment_id_fkey"

  add_foreign_key "subscriptions", ["person_id"], "people", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "subscriptions_person_id_fkey"
  add_foreign_key "subscriptions", ["sale_id"], "sales", ["id"], :name => "subscriptions_sale_id_fkey"
  add_foreign_key "subscriptions", ["sale_line_id"], "sale_lines", ["id"], :name => "subscriptions_sale_line_id_fkey"

  add_foreign_key "zone_natures", ["parent_id"], "zone_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zone_natures_parent_id_fkey"

  add_foreign_key "zones", ["country_id"], "countries", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_country_id_fkey"
  add_foreign_key "zones", ["nature_id"], "zone_natures", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_nature_id_fkey"
  add_foreign_key "zones", ["parent_id"], "zones", ["id"], :on_update => :restrict, :on_delete => :restrict, :name => "zones_parent_id_fkey"

end
