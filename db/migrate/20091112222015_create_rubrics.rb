class CreateRubrics < ActiveRecord::Migration
  def self.up

    create_table :rubrics do |t|
      t.column :name,          :string, :null=>false
      t.column :code,          :string, :null=>false
      t.column :logo,          :string
      t.column :description,   :text
      t.column :parent_id,     :integer, :references=>:rubrics
      t.column :rubrics_count, :integer, :null=>false, :default=>0
    end
    add_index :rubrics, :parent_id

    create_table :configurations do |t|
      t.column :contact_article_id,  :integer,  :references=>:articles
      t.column :about_article_id,    :integer,  :references=>:articles
      t.column :legals_article_id,   :integer,  :references=>:articles
      t.column :home_rubric_id,      :integer,  :references=>:rubrics
      t.column :news_rubric_id,      :integer,  :references=>:rubrics
      t.column :agenda_rubric_id,    :integer,  :references=>:rubrics
    end

    home_id = insert "INSERT INTO rubrics (name, code) VALUES ('Accueil', 'accueil')"
    news_id = insert "INSERT INTO rubrics (name, code) VALUES ('Nouvelles', 'nouvelles')"
    agenda_id = insert "INSERT INTO rubrics (name, code) VALUES ('Agenda', 'agenda')"
    empty_id = insert "INSERT INTO rubrics (name, code) VALUES ('Sans-rubrique', 'norubric')"
    contact_id = select_value("SELECT id FROM articles WHERE natures LIKE '% contact %'")
    legals_id = select_value("SELECT id FROM articles WHERE natures LIKE '% legals %'")
    about_id = select_value("SELECT id FROM articles WHERE natures LIKE '% about_us %'")

    execute "INSERT INTO configurations (home_rubric_id, news_rubric_id, agenda_rubric_id, contact_article_id, legals_article_id, about_article_id) VALUES (#{home_id}, #{news_id}, #{agenda_id}, #{contact_id}, #{legals_id}, #{about_id})"

    add_column :images, :locked,    :boolean, :null=>false, :default=>false
    add_column :images, :deleted,   :boolean, :null=>false, :default=>false
    add_column :images, :published, :boolean, :null=>false, :default=>true
    add_column :articles, :rubric_id, :integer, :references=>:rubrics
    add_column :articles, :opened,    :boolean, :null=>false, :default=>false

    execute "UPDATE articles SET opened=true"
    execute "UPDATE articles SET rubric_id=#{agenda_id} WHERE natures LIKE '% agenda %'"
    execute "UPDATE articles SET rubric_id=#{home_id} WHERE natures LIKE '% home %'"
    execute "UPDATE articles SET rubric_id=#{news_id}, opened=false WHERE natures LIKE '% blog %'"
    execute "UPDATE articles SET rubric_id=#{empty_id}, opened=false WHERE rubric_id IS NULL"

    rename_column(:articles, :natures, :bad_natures)
  end

  def self.down
    rename_column(:articles, :bad_natures, :natures)

    remove_column :articles, :rubric_id
    remove_column :images, :published
    remove_column :images, :deleted
    remove_column :images, :locked

    drop_table :configurations
    drop_table :rubrics
  end
end
