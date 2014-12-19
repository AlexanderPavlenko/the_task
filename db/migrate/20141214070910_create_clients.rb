class CreateClients < Framework::Migration
  use_database :default

  def up
    create_table :clients do |t|
      t.text :name
      t.decimal :local_account_amount
      t.timestamps
    end
  end

  def down
    drop_table :clients
  end
end
