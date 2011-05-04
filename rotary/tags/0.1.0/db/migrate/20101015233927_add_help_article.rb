class AddHelpArticle < ActiveRecord::Migration
  def self.up
    add_column :configurations, :help_article_id, :integer, :references=>:articles
    add_column :configurations, :chasing_up_days, :string
    add_column :configurations, :chasing_up_letter_before_expiration, :text
    add_column :configurations, :chasing_up_letter_after_expiration, :text
  end

  def self.down
    remove_column :configurations, :chasing_up_letter_after_expiration, :text
    remove_column :configurations, :chasing_up_letter_before_expiration, :text
    remove_column :configurations, :chasing_up_days, :string
    remove_column :configurations, :help_article_id
  end
end
