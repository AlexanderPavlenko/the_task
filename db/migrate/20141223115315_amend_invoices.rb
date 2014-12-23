class AmendInvoices < Framework::Migration
  use_database :default

  def up
    add_column :invoices, :paid_at, :datetime
    add_column :invoices, :overdue_at, :date
  end

  def down
    remove_column :invoices, :paid_at
    remove_column :invoices, :overdue_at
  end
end
