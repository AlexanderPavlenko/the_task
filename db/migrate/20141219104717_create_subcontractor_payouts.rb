class CreateSubcontractorPayouts < Framework::Migration
  use_database :default

  def up
    create_table :subcontractor_payouts do |t|
      t.references :job
      t.decimal :amount
      t.timestamps
    end
  end

  def down
    drop_table :subcontractor_payouts
  end
end
