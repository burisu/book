class CreateRubrics < ActiveRecord::Migration
  def self.up

    create_table :rubrics do |t|
      t.column :name,          :string, :null=>false
      t.column :code,          :string, :null=>false
      t.column :logo,          :string
      t.column :description,   :text
      t.column :parent_id,     :integer, :references=>:rubrics
      t.column :rubrics_count, :integer, :null=>false, :default=>0
      t.timestamps
    end
    add_index :rubrics, :parent_id

    create_table :configurations do |t|
      t.column :contact_article_id,  :integer,  :references=>:articles
      t.column :about_article_id,    :integer,  :references=>:articles
      t.column :legals_article_id,   :integer,  :references=>:articles
      t.column :home_rubric_id,      :integer,  :references=>:rubrics
      t.column :news_rubric_id,      :integer,  :references=>:rubrics
      t.column :agenda_rubric_id,    :integer,  :references=>:rubrics
      t.timestamps
    end

    create_table :articles_mandate_natures, :id=>false do |t|
      t.column :article_id,              :integer, :references=>:articles
      t.column :mandate_nature_id,       :integer, :references=>:mandate_natures
      t.timestamps
    end

    config = {}
    config[:home_rubric_id] = insert "INSERT INTO rubrics (name, code, created_at, updated_at) VALUES ('Accueil', 'accueil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    config[:news_rubric_id] = insert "INSERT INTO rubrics (name, code, created_at, updated_at) VALUES ('Nouvelles', 'nouvelles', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    config[:agenda_rubric_id] = insert "INSERT INTO rubrics (name, code, created_at, updated_at) VALUES ('Agenda', 'agenda', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    # config[:empty_id] = insert "INSERT INTO rubrics (name, code, created_at, updated_at) VALUES ('Sans-rubrique', 'norubric', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    config[:contact_article_id] = select_value("SELECT id FROM articles WHERE natures LIKE '% contact %'")
    config[:legals_article_id] = select_value("SELECT id FROM articles WHERE natures LIKE '% legals %'")
    config[:about_article_id] = select_value("SELECT id FROM articles WHERE natures LIKE '% about_us %'")

    # execute "INSERT INTO configurations (home_rubric_id, news_rubric_id, agenda_rubric_id, contact_article_id, legals_article_id, about_article_id) VALUES (#{home_id}, #{news_id}, #{agenda_id}, #{contact_id}, #{legals_id}, #{about_id})"
    execute "INSERT INTO configurations(home_rubric_id, created_at, updated_at) VALUES (NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    for k, v in config
      execute "UPDATE configurations SET #{k}=#{v}" unless v.blank?
    end

    add_column :images, :locked,    :boolean, :null=>false, :default=>false
    add_column :images, :deleted,   :boolean, :null=>false, :default=>false
    add_column :images, :published, :boolean, :null=>false, :default=>true
    add_column :articles, :rubric_id, :integer, :references=>:rubrics
    # add_column :articles, :opened,    :boolean, :null=>false, :default=>false

    # execute "UPDATE articles SET opened=true"
    execute "UPDATE articles SET rubric_id=#{config[:agenda_rubric_id]} WHERE natures LIKE '% agenda %'"
    execute "UPDATE articles SET rubric_id=#{config[:home_rubric_id]} WHERE natures LIKE '% home %'"
    # execute "UPDATE articles SET rubric_id=#{config[:news_rubric_id]} WHERE natures LIKE '% blog %'"
    execute "UPDATE articles SET rubric_id=#{config[:news_rubric_id]} WHERE rubric_id IS NULL"
    # execute "UPDATE articles SET opened=true WHERE id IN (#{contact_id}, #{legals_id}, #{about_id})"

    rename_column(:articles, :natures, :bad_natures)
  end

  def self.down
    rename_column(:articles, :bad_natures, :natures)

    # remove_column :articles, :opened
    remove_column :articles, :rubric_id
    remove_column :images, :published
    remove_column :images, :deleted
    remove_column :images, :locked

    drop_table :articles_mandate_natures
    drop_table :configurations
    drop_table :rubrics
  end
end
