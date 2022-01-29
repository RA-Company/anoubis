class CreateMenuLocales < ActiveRecord::Migration[6.0]
  def change
    create_table :menu_locales do |t|
      t.references :menu, foreign_key: true
      t.integer :locale, null: false, default: 0
      t.string :title, limit: 200
      t.string :page_title, limit: 200
      t.string :short_title, limit: 200

      t.timestamps
    end
    add_index :menu_locales, [:menu_id, :locale], unique: true
  end
end
