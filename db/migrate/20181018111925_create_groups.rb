class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.string :ident, limit: 50
      t.references :system, foreign_key: true, index: true
      t.string :full_ident, limit: 70

      t.timestamps
    end
    add_index :groups, [:ident, :system_id], unique: true
    add_index :groups, [:full_ident], unique: true
  end
end
