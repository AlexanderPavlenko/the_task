class CreateLocalAccountTransactions < Framework::Migration
  use_database :default

  def up
    create_table :local_account_transactions do |t|
      t.references :transactionable, polymorphic: true
      t.decimal :amount
      t.decimal :local_account_amount_before
      t.timestamps
    end
  end

  def down
    drop_table :local_account_transactions
  end
end
