class CreateTenants < ActiveRecord::Migration[6.0]
  def change
    create_table :tenants do |t|
      t.string :title, limit: 100
      t.string :ident, limit: 10
      t.integer :state, default: 0

      t.timestamps
    end
    add_index :tenants, [:title], unique: true
    add_index :tenants, [:ident], unique: true
  end
end
