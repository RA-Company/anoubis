class CreateSystemMenus < ActiveRecord::Migration[6.0]
  def change
    create_table :system_menus do |t|
      t.references :system, foreign_key: true
      t.references :menu, foreign_key: true

      t.timestamps
    end
    add_index :system_menus, [:system_id, :menu_id], unique: true
  end
end
