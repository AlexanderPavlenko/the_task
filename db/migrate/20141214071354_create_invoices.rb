class CreateInvoices < Framework::Migration
  use_database :default

  def up
    create_table :invoices do |t|
      t.references :job
      t.decimal :amount
      t.integer :state
      t.timestamps
    end
  end

  def down
    drop_table :invoices
  end
end
