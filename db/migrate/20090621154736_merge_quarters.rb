class MergeQuarters < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :started_on, :date
    add_column :questionnaires, :stopped_on, :date
    add_index :questionnaires, :started_on
    add_index :questionnaires, :stopped_on

    drop_table :quarters

    rename_column :questions, :explaning, :explanation

  end

  def self.down

    rename_column :questions, :explanation, :explaning

    create_table :quarters do |t|
      t.column :launched_on,       :date,    :null=>false
      t.column :questionnaire_id,  :integer, :null=>false, :references=>:questionnaires
    end
    add_index :quarters, :questionnaire_id

    remove_column :questionnaires, :stopped_on
    remove_column :questionnaires, :started_on
  end
end
