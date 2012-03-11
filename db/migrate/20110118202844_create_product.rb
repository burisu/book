# -*- coding: utf-8 -*-
class CreateProduct < ActiveRecord::Migration
  PAYMENT_COLS = [:number, :sequential_number, :authorization_number, :payment_type, :card_type, :transaction_number, :country, :error_code, :card_expired_on, :payer_country, :signature, :bin6]


  def self.up

    create_table :products do |t|
      t.column :name,             :string, :null=>false
      t.column :description,      :text
      t.column :amount,           :decimal, :precision=>16, :scale=>2, :null=>false, :default=>0
      t.column :unit,             :string, :null=>false, :default=>"unités"
      t.column :deadlined,        :boolean, :null=>false, :default=>false
      t.column :started_on,       :date
      t.column :stopped_on,       :date
      t.column :storable,         :boolean, :null=>false, :default=>false
      t.column :initial_quantity, :decimal, :precision=>16, :scale=>2, :null=>false, :default=>0
      t.column :current_quantity, :decimal, :precision=>16, :scale=>2, :null=>false, :default=>0
      t.column :subscribing,      :boolean, :null=>false, :default=>false
      t.column :subscribing_started_on, :date
      t.column :subscribing_stopped_on, :date
      t.column :personal,         :boolean, :null=>false, :default=>false
      t.timestamps
    end
    add_index :products, :name

    create_table :payments do |t|
      t.column :amount,               :decimal, :precision=>16, :scale=>2, :null=>false, :default=>0
      t.column :used_amount,          :decimal, :precision=>16, :scale=>2, :null=>false, :default=>0
      t.column :payer_id,             :integer, :references=>:people
      t.column :payer_email,          :string, :null=>false
      t.column :mode,                 :string, :null=>false
      t.column :number,               :string, :limit=>16
      t.column :sequential_number,    :string
      t.column :authorization_number, :string
      t.column :payment_type,         :string
      t.column :card_type,            :string
      t.column :transaction_number,   :string
      t.column :country,              :string
      t.column :error_code,           :string
      t.column :card_expired_on,      :date
      t.column :payer_country,        :string
      t.column :signature,            :string
      t.column :bin6,                 :string
      t.column :sid,                  :integer
      t.timestamps
    end
    add_index :payments, :number
    add_index :payments, :payer_id
    add_index :payments, :mode

    execute "INSERT INTO payments (payer_id, payer_email, amount, used_amount, mode, sid, #{PAYMENT_COLS.join(', ')}, created_at, updated_at) SELECT person_id, people.email, amount, amount, payment_mode, subscriptions.id, #{PAYMENT_COLS.join(', ')}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM subscriptions JOIN people ON (person_id=people.id) WHERE state = 'P'"
    
    add_column :subscriptions, :code, :string, :limit=>64
    execute "UPDATE subscriptions SET code = number"
    for column in PAYMENT_COLS
      remove_column :subscriptions, column
    end
    remove_column :subscriptions, :payment_mode
    rename_column :subscriptions, :code, :number

    create_table :sales do |t|
      t.column :number,       :string,  :null=>false
      t.column :state,        :string,  :null=>false
      t.column :comment,      :text
      t.column :client_id,    :integer, :references=>:people
      t.column :client_email, :string,  :null=>false
      t.column :amount,       :decimal, :precision=>16, :scale=>2
      t.column :created_on,   :date,    :null=>false
      t.column :payment_id,   :integer, :references=>:payments
      t.column :sid,                  :integer
      t.timestamps
    end
    add_index :sales, :number
    add_index :sales, :client_id
    add_index :sales, :payment_id
    add_index :sales, :created_on

    execute "INSERT INTO sales (number, state, comment, client_id, client_email, amount, created_on, payment_id, sid, created_at, updated_at) SELECT 'V'||subscriptions.number, state, note, person_id, people.email, subscriptions.amount, subscriptions.created_at::DATE, payments.id, subscriptions.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM subscriptions JOIN people ON (subscriptions.person_id=people.id) LEFT JOIN payments ON (payments.sid=subscriptions.id)"

    remove_column :subscriptions, :amount
    remove_column :subscriptions, :note
    remove_column :subscriptions, :state

    create_table :sale_lines do |t|
      t.column :sale_id,       :integer, :null=>false, :references=>:sales
      t.column :product_id,    :integer, :null=>false, :references=>:products
      t.column :name,          :string, :null=>false
      t.column :description,   :text
      t.column :unit_amount,   :decimal, :precision=>16, :scale=>2, :null=>false, :default=>0
      t.column :quantity,      :decimal, :precision=>16, :scale=>2, :null=>false, :default=>0
      t.column :amount,        :decimal, :precision=>16, :scale=>2, :null=>false, :default=>0
      t.column :sid,                  :integer
      t.timestamps
    end
    add_index :sale_lines, :sale_id
    add_index :sale_lines, :product_id

    execute "INSERT INTO products (name, amount, subscribing, subscribing_started_on, subscribing_stopped_on, created_at, updated_at) VALUES ('Adhésion 1 an', 10.5, true, '2009-09-01', '2010-10-31', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    execute "INSERT INTO sale_lines (sale_id, product_id, name, description, unit_amount, quantity, amount, sid, created_at, updated_at) SELECT id, 1, 'Adhésion 1 an', 'Année 2010', CASE WHEN amount/10.5 = ROUND(amount/10.5) AND amount > 10.5 THEN 10.5 ELSE amount END, CASE WHEN amount/10.5 = ROUND(amount/10.5) AND amount > 10.5 THEN amount/10.5 ELSE 1 END, amount, sid, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM sales"

    add_column :subscriptions, :sale_id, :integer, :references=>:sales
    add_column :subscriptions, :sale_line_id, :integer, :references=>:sale_lines

    execute "UPDATE subscriptions SET sale_id = sl.sale_id, sale_line_id=sl.id  FROM sale_lines AS sl WHERE sl.sid=subscriptions.id"

    remove_column :payments,   :sid
    remove_column :sales,      :sid
    remove_column :sale_lines, :sid

    create_table :guests do |t|
      t.column :sale_line_id, :integer, :references=>:sale_lines
      t.column :sale_id,      :integer, :references=>:sales
      t.column :product_id,   :integer, :references=>:products
      t.column :first_name,   :string
      t.column :last_name,    :string
      t.column :email,        :string
      t.column :zone_id,      :integer, :references=>:zones
      t.column :annotation,   :text
      t.timestamps
    end
    add_index :guests, :sale_line_id
    add_index :guests, :sale_id
    add_index :guests, :product_id
    add_index :guests, :zone_id

  end

  def self.down
    drop_table :guests

    add_column :payments,   :sid, :integer
    add_column :sales,      :sid, :integer
    add_column :sale_lines, :sid, :integer

    execute "UPDATE payments SET sid=subscriptions.id FROM subscriptions JOIN sales ON (sales.id=subscriptions.sale_id) WHERE sales.payment_id=payments.id"
    execute "UPDATE sales SET sid=subscriptions.id FROM subscriptions WHERE sales.id=subscriptions.sale_id"
    execute "UPDATE sale_lines SET sid=subscriptions.id FROM subscriptions WHERE sale_lines.id=subscriptions.sale_line_id"
    
    remove_column :subscriptions, :sale_line_id
    remove_column :subscriptions, :sale_id
    
    drop_table :sale_lines

    add_column :subscriptions, :state, :string
    add_column :subscriptions, :note, :text
    add_column :subscriptions, :amount, :decimal, :precision=>16, :scale=>2, :null=>false, :default=>0 

    execute "UPDATE subscriptions SET state = s.state, note = s.comment, amount = s.amount FROM sales AS s WHERE s.sid=subscriptions.id"

    drop_table :sales

    rename_column :subscriptions, :number, :code
    add_column :subscriptions, :payment_mode, :string
    for column in PAYMENT_COLS.reverse
      add_column :subscriptions, column, (column.to_s.match(/_on$/) ? :date : :string)
    end
    execute "UPDATE subscriptions SET number = code"
    execute "UPDATE subscriptions SET payment_mode = p.mode, "+PAYMENT_COLS.collect{|x| "#{x} = p.#{x}"}.join(', ')+" FROM payments AS p WHERE p.sid=subscriptions.id"
    remove_column :subscriptions, :code
 
    drop_table :payments

    drop_table :products
  end
end
