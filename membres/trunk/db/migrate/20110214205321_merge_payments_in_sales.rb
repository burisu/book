class MergePaymentsInSales < ActiveRecord::Migration
  PAYMENT_COLS = [:sequential_number, :authorization_number, :payment_type, :card_type, :transaction_number, :country, :error_code, :card_expired_on, :payer_country, :signature, :bin6]

  def self.up
    for column in PAYMENT_COLS
      add_column :sales, column, (column == :card_expired_on ? :date : :string)
    end
    add_column :sales, :payment_mode, :string, :null=>false, :default=>"none"
    add_index :sales, :payment_mode
    add_column :sales, :payment_number, :string

    execute "UPDATE sales SET state=CASE WHEN p.received IS TRUE THEN 'P' ELSE state END, payment_mode = p.mode, payment_number=p.number, "+PAYMENT_COLS.collect{|c| "#{c}=p.#{c}"}.join(", ")+" FROM payments AS p WHERE sales.payment_id = p.id"
    
    remove_column :sales, :payment_id
    drop_table :payments
  end

  def self.down
    create_table "payments", :force => true do |t|
      t.decimal  "amount",                             :precision => 16, :scale => 2, :default => 0.0,   :null => false
      t.decimal  "used_amount",                        :precision => 16, :scale => 2, :default => 0.0,   :null => false
      t.integer  "payer_id", :references=>:people
      t.string   "payer_email",                                                                          :null => false
      t.string   "mode",                                                                                 :null => false
      t.string   "number",               :limit => 16
      t.string   "sequential_number"
      t.string   "authorization_number"
      t.string   "payment_type"
      t.string   "card_type"
      t.string   "transaction_number"
      t.string   "country"
      t.string   "error_code"
      t.date     "card_expired_on"
      t.string   "payer_country"
      t.string   "signature"
      t.string   "bin6"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "lock_version",                                                      :default => 0
      t.boolean  "received",                                                          :default => false, :null => false
      t.column :sale_id, :integer
    end

    add_index :payments, :number
    add_index :payments, :payer_id
    add_index :payments, :mode
    
    add_column :sales, :payment_id, :integer
    
    execute "INSERT INTO payments (sale_id, received, used_amount, payer_id, payer_email, mode, number, created_at, updated_at, "+PAYMENT_COLS.join(", ")+") SELECT id, true, amount, client_id, client_email, COALESCE(payment_mode, 'none'), payment_number, created_at, updated_at, "+PAYMENT_COLS.join(", ")+" FROM sales WHERE state='P'"
    execute "UPDATE sales SET payment_id=p.id FROM payments AS p WHERE sale_id=sales.id"
    remove_column :payments, :sale_id
    
    remove_column :sales, :payment_number
  
    remove_column :sales, :payment_mode
    for column in PAYMENT_COLS.reverse
      remove_column :sales, column
    end
  end
end
