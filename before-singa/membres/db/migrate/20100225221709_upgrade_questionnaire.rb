class UpgradeQuestionnaire < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :promotion_id, :integer
  end

  def self.down
    remove_column :questionnaires, :promotion_id
  end
end
