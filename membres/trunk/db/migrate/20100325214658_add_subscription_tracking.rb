class AddSubscriptionTracking < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :number, :string, :limit=>16
    add_column :subscriptions, :state,  :string, :null=>false, :default=>"I", :limit=>1
    add_column :subscriptions, :sequential_number,    :string
    add_column :subscriptions, :authorization_number, :string
    add_column :subscriptions, :payment_type,         :string
    add_column :subscriptions, :card_type,            :string
    add_column :subscriptions, :transaction_number,   :string
    add_column :subscriptions, :country,              :string
    add_column :subscriptions, :error_code,           :string
    add_column :subscriptions, :card_expired_on,      :date
    add_column :subscriptions, :payer_country,        :string
    add_column :subscriptions, :signature,            :string
    add_column :subscriptions, :bin6,                 :string
    execute "UPDATE subscriptions SET number='ABCDEF'||LPAD(id::text, 6, '0'), state='P'"


    add_column :configurations, :subscription_price, :decimal, :null=>false, :default=>0.0
    add_column :configurations, :store_introduction, :text
    execute "UPDATE configurations SET subscription_price=10.50"

  end

  def self.down
    remove_column :configurations, :store_introduction
    remove_column :configurations, :subscription_price

    remove_column :subscriptions, :sequential_number
    remove_column :subscriptions, :authorization_number
    remove_column :subscriptions, :payment_type
    remove_column :subscriptions, :card_type
    remove_column :subscriptions, :transaction_number
    remove_column :subscriptions, :country
    remove_column :subscriptions, :error_code
    remove_column :subscriptions, :card_expired_on
    remove_column :subscriptions, :payer_country
    remove_column :subscriptions, :signature
    remove_column :subscriptions, :bin6
    remove_column :subscriptions, :state
    remove_column :subscriptions, :number
  end
end
