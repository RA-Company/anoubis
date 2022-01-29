class CreateTenantSystems < ActiveRecord::Migration[6.0]
  def change
    create_table :tenant_systems do |t|
      t.references :tenant, foreign_key: true
      t.references :system, foreign_key: true

      t.timestamps
    end
    add_index :tenant_systems, [:tenant_id, :system_id], unique: true
  end
end
