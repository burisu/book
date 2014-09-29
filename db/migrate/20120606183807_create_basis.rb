class CreateBasis < ActiveRecord::Migration
  def change
    # Activities
    create_table :activities do |t|
      t.belongs_to :sector, :null=>false
      t.string :title
      t.string :name
      t.string :code
      t.integer :lock_version, :null=>false, :default=>0
      t.timestamps
    end
    add_index :activities, :sector_id

    # Activity <=> Organigram
    create_table :activities_organigrams, :id=>false do |t|
      t.belongs_to :activity, :null=>false
      t.belongs_to :organigram, :null=>false
    end    
    add_index :activities_organigrams, :activity_id
    add_index :activities_organigrams, :organigram_id

    # ActivitySectors
    create_table :activity_sectors do |t|
      t.string :name
      t.string :code
      t.text :description
      t.integer :lock_version, :null=>false, :default=>0
      t.timestamps
    end    

    # Answer
    create_table :answers do |t|
      t.belongs_to :surveyance, :null => false
      t.belongs_to :question, :null => false
      t.text    :string_value
      t.boolean :boolean_value
      t.date    :date_value
      t.decimal :decimal_value
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :answers, :surveyance_id
    add_index :answers, :question_id

    # Article
    create_table :articles do |t|
      t.belongs_to :author
      t.belongs_to :visibility_group
      t.belongs_to :rubric
      t.string :title
      t.text :introduction
      t.text :body
      t.string :visibility
      t.string :state
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :articles, :author_id
    add_index :articles, :visibility_group_id
    add_index :articles, :rubric_id

    # Contact
    create_table :contacts do |t|
      t.belongs_to :user, :null=>false
      t.belongs_to :nature, :null=>false
      t.string :canal, :null=>false
      t.string :coordinate, :null=>false
      t.string :address_line_2   #, :limit => 38
      t.string :address_line_3   #, :limit => 38
      t.string :address_line_4   #, :limit => 38
      t.string :address_line_5   #, :limit => 38
      t.string :address_line_6   #, :limit => 38
      t.string :address_postcode #, :limit => 38
      t.string :address_city     #, :limit => 38
      t.string :address_country  #, :limit => 38
      t.boolean :receiving, :null=>false, :default=>false
      t.boolean :sending, :null=>false, :default=>false
      t.boolean :by_default, :null=>false, :default=>false
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :contacts, :user_id
    add_index :contacts, :nature_id
    add_index :contacts, :canal
    
    # ContactNature
    create_table :contact_natures do |t|
      t.string :name, :null=>false
      t.string :canal, :null=>false
      t.integer :lock_version, :null=>false, :default=>0
      t.timestamps
    end
    add_index :contact_natures, :canal

    # Event
    create_table :events do |t|
      t.belongs_to :nature
      t.belongs_to :group
      t.belongs_to :author
      t.string :name
      t.text :description
      t.datetime :started_at
      t.datetime :stopped_at
      t.text :place
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :events, :nature_id
    add_index :events, :group_id
    add_index :events, :author_id

    # EventNature
    create_table :event_natures do |t|
      t.string :name
      t.text :description
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    # Group
    create_table :groups do |t|
      t.string :name
      t.string :title
      t.string :slogan
      t.text :description
      t.string :url
      t.string :web_mode
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    # GroupIntervention
    create_table :group_interventions do |t|
      t.belongs_to :event
      t.belongs_to :group
      t.belongs_to :nature
      t.datetime :started_at
      t.datetime :stopped_at
      t.text :description
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :group_interventions, :event_id
    add_index :group_interventions, :group_id
    add_index :group_interventions, :nature_id

    # GroupLink
    create_table :group_links do |t|
      t.belongs_to :nature
      t.belongs_to :group_1
      t.belongs_to :group_2
      t.text :comment
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :group_links, :nature_id
    add_index :group_links, :group_1_id
    add_index :group_links, :group_2_id

    # GroupLinkNature
    create_table :group_link_natures do |t|
      t.string :name
      t.string :name_1_to_2
      t.string :name_2_to_1
      t.boolean :symetric, :null => false, :default => false
      t.text :description
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    # Honour
    create_table :honours do |t|
      t.belongs_to :nature
      t.string :name
      t.string :code
      t.string :abbreviation
      t.integer :position
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :honours, :nature_id

    # HonourNature
    create_table :honour_natures do |t|
      t.string :name
      t.string :code
      t.text :description
      t.text :comment
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    # InterventionNature
    create_table :intervention_natures do |t|
      t.belongs_to :event_nature
      t.string :type
      t.string :name
      t.text :description
      t.integer :minimum_quantity, :null => false, :default => 0
      t.integer :maximum_quantity, :null => false, :default => 0
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :intervention_natures, :event_nature_id

    # Invitation
    create_table :invitations do |t|
      t.belongs_to :event
      t.belongs_to :guest
      t.belongs_to :godfather
      t.boolean :invited, :null => false, :default => false
      t.boolean :inscribed, :null => false, :default => false
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :invitations, :event_id
    add_index :invitations, :guest_id
    add_index :invitations, :godfather_id

    # Organigram
    create_table :organigrams do |t|
      t.string :name
      t.string :code
      t.text :description
      t.integer :lock_version, :null=>false, :default=>0
      t.timestamps
    end    

    # Profession
    create_table :professions do |t|
      t.belongs_to :organigram
      t.string :name
      t.string :code
      t.boolean :printed, :null=>false, :default=>false
      t.integer :lock_version, :null=>false, :default=>0
      t.timestamps
    end    
    add_index :professions, :organigram_id

    # Question
    create_table :questions do |t|
      t.belongs_to :survey
      t.string :name
      t.text :description
      t.string :nature
      t.integer :position
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :questions, :survey_id

    # Remittance
    create_table :remittances do |t|
      t.belongs_to :person, :null=>false
      t.belongs_to :honour, :null=>false
      t.date :given_on
      t.text :comment
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :remittances, :person_id
    add_index :remittances, :honour_id

    # Rubric
    create_table :rubrics do |t|
      t.string :name
      t.text :description
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    # Survey
    create_table :surveys do |t|
      t.belongs_to :author
      t.string :name
      t.text :description
      t.text :comment
      t.boolean :published, :null => false, :default => false
      t.date :started_on
      t.date :stopped_on
      t.integer :items_count, :null=>false, :default=>0
      t.integer :answers_count, :null=>false, :default=>0
      t.integer :lock_version, :null=>false, :default=>0
      t.timestamps
    end
    add_index :surveys, :author_id

    # Surveyance
    create_table :surveyances do |t|
      t.belongs_to :survey, :null => false
      t.belongs_to :surveyee, :null => false
      t.string :state
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :surveyances, :survey_id 
    add_index :surveyances, :surveyee_id

    # UserIntervention
    create_table :user_interventions do |t|
      t.belongs_to :event
      t.belongs_to :user
      t.belongs_to :nature
      t.belongs_to :group_intervention
      t.datetime :started_at
      t.datetime :stopped_at
      t.text :description
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end
    add_index :user_interventions, :event_id
    add_index :user_interventions, :user_id
    add_index :user_interventions, :nature_id
    add_index :user_interventions, :group_intervention_id




    create_table :incoming_payments do |t|
      t.belongs_to :payer
      t.string :number
      t.decimal :amount, :null => false, :default => 0
      t.decimal :used_amount, :null => false, :default => 0
      t.string :nature
      t.date :paid_on
      t.string :bank_name
      t.string :account_number
      t.string :payment_number
      t.text :informations
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    create_table :incoming_payment_uses do |t|
      t.belongs_to :payment
      t.belongs_to :sale
      t.decimal :used_amount, :null => false, :default => 0
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    create_table :products do |t|
      t.belongs_to :group
      t.belongs_to :event
      t.string :name
      t.text :description
      t.string :unit
      t.decimal :pretax_amount, :null => false, :default => 0
      t.decimal :amount, :null => false, :default => 0
      t.boolean :active
      t.boolean :deadlined
      t.date :started_on
      t.date :stopped_on
      t.boolean :limited
      t.decimal :initial_quantity
      t.decimal :current_quantity
      t.boolean :guest_only
      t.boolean :authorize_gotfathering      
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    create_table :sales do |t|
      t.belongs_to :client
      t.string :number
      t.decimal :amount
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    create_table :sale_lines do |t|
      t.belongs_to :sale
      t.belongs_to :product
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    create_table :mandates do |t|
      t.belongs_to :user
      t.belongs_to :nature
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    create_table :mandate_natures do |t|
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    create_table :rights do |t|
      t.belongs_to :mandate_nature
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    create_table :users do |t|
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    create_table :labels do |t|
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

    create_table :tags do |t|
      t.integer :lock_version, :null=>false, :default=>0      
      t.timestamps
    end

  end
end
