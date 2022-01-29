class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :login, limit: 65, null: false
      t.string :email, limit: 50, null: false
      t.string :name, limit: 100, null: false
      t.string :surname, limit: 100, null: false
      t.string :timezone, limit: 30, null: false
      t.string :locale, limit: 10, null: false, default: 'ru-RU'
      t.integer :timeout, null: false, default: 3600
      t.string :phone, limit: 30
      t.string :password_digest, limit: 60, null: false
      t.string :auth_key, limit: 32
      t.string :recover_key, limit: 32
      t.integer :status, null: false, default: 0
      t.references :tenant, index: true, foreign_key: true
      t.binary :uuid_bin, limit: 16

      t.timestamps
    end
    add_index :users, [:login], unique: true
    add_index :users, [:email, :tenant_id], unique: true
    add_index :users, [:uuid_bin], unique: true
  end
end
