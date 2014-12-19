class CreateSubcontractors < Framework::Migration
  use_database :default

  def up
    create_table :subcontractors do |t|
      t.decimal :rate
      t.decimal :local_account_amount
      t.timestamps
    end
  end

  def down
    drop_table :subcontractors
  end
end
