class CreateSystems < ActiveRecord::Migration[6.0]
  def change
    create_table :systems do |t|
      t.string :ident, limit: 15

      t.timestamps
    end
    add_index :systems, [:ident], unique: true
  end
end
