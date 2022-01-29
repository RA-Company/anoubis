class CreateGroupMenus < ActiveRecord::Migration[6.0]
  def change
    create_table :group_menus do |t|
      t.references :menu, index: true, foreign_key: true, default: 0
      t.references :group, index: true, foreign_key: true, default: 0
      t.integer :access

      t.timestamps
    end
    add_index :group_menus, [:menu_id, :group_id], unique: true
  end
end
