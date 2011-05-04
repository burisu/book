class AddQuestionnaire < ActiveRecord::Migration
  def self.up

    create_table :questionnaires do |t|
      t.column :name,        :string,  :null=>false, :limit=>64
      t.column :intro,       :text
      t.column :comment,     :text
    end
    add_index :questionnaires, :name, :unique=>true

    create_table :questions do |t|
      t.column :name,              :string,  :null=>false
      t.column :explaning,         :text
      t.column :position,          :integer
      t.column :questionnaire_id,  :integer, :references=>:questionnaires
    end
    add_index :questions, :questionnaire_id

    create_table :quarters do |t|
      t.column :launched_on,       :date,    :null=>false
      t.column :questionnaire_id,  :integer, :null=>false, :references=>:questionnaires
    end
    add_index :quarters, :questionnaire_id

    create_table :answers do |t|
      t.column :created_on,        :date
      t.column :ready,             :boolean, :null=>false, :default=>false
      t.column :locked,            :boolean, :null=>false, :default=>false 
      t.column :person_id,         :integer, :null=>false, :references=>:people
      t.column :questionnaire_id,  :integer, :null=>false, :references=>:questionnaires
    end
    add_index :answers, :person_id
    add_index :answers, :questionnaire_id

    create_table :answer_items do |t|
      t.column :content,           :text
      t.column :answer_id,         :integer, :null=>false, :references=>:answers
      t.column :question_id,       :integer, :null=>false, :references=>:questions
    end
    add_index :answer_items, :answer_id
    add_index :answer_items, :question_id
  end

  def self.down
    drop_table :answer_items
    drop_table :answers
    drop_table :quarters
    drop_table :questions
    drop_table :questionnaires
  end
end
