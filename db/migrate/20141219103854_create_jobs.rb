class CreateJobs < Framework::Migration
  use_database :default

  def up
    create_table :jobs do |t|
      t.references :client
      t.references :subcontractor
      t.integer :state
      t.date :start_date
      t.date :end_date
      t.decimal :client_rate
      t.decimal :discount
      t.timestamps
    end
  end

  def down
    drop_table :jobs
  end
end
