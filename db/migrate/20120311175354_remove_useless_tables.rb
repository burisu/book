class RemoveUselessTables < ActiveRecord::Migration
  COUNTRY_COLUMNS = {
    :groups => ["country_id"],
    :people => ["country_id", "arrival_country_id", "departure_country_id"],
    :periods => ["country_id"]
  }
  def up
    drop_table :emails
    drop_table :person_versions

    languages = select_all("SELECT id, COALESCE(LOWER(TRIM(iso639)), id::TEXT) AS code FROM languages")
    add_column :articles, :language, :string, :limit=>2
    add_index :articles, :language
    execute "UPDATE articles SET language = CASE "+languages.collect{|l| "WHEN language_id=#{l['id']} THEN '#{l['code']}'"}.join(" ")+" ELSE 'fr' END" if languages.size > 0
    remove_column :articles, :language_id

    add_column :people, :language, :string, :limit=>2
    add_index :people, :language
    execute "UPDATE people SET language = CASE "+languages.collect{|l| "WHEN c.language_id=#{l['id']} THEN '#{l['code']}'"}.join(" ")+" ELSE 'fr' END FROM countries AS c WHERE country_id=c.id" if languages.size > 0

    countries = select_all("SELECT id, COALESCE(LOWER(TRIM(iso3166)), id::TEXT) AS code FROM countries")
    for table, changes in COUNTRY_COLUMNS
      for id_column in changes
        code_column = id_column[0..-4]
        add_column table, code_column, :string, :limit=>2
        add_index table, code_column
        execute "UPDATE #{table} SET #{code_column} = CASE "+countries.collect{|l| "WHEN #{id_column}=#{l['id']} THEN '#{l['code']}'"}.join(" ")+" ELSE 'fr' END" if countries.size > 0
        remove_column table, id_column
      end
    end

    drop_table :countries
    execute "DROP TABLE languages CASCADE"
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
