class CreateRefunds < Framework::Migration
  use_database :default

  def up
    create_table :refunds do |t|
      t.references :job
      t.decimal :amount
      t.timestamps
    end
  end

  def down
    drop_table :refunds
  end
end
