class DropCache < ActiveRecord::Migration
  def self.up
    remove_column :articles, :title_h
    remove_column :articles, :intro_h
    remove_column :articles, :content_h
  end

  def self.down
    add_column :articles, :title_h, :text
    add_column :articles, :intro_h, :text
    add_column :articles, :content_h, :text
  end
end
