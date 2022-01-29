class CreateSystemLocales < ActiveRecord::Migration[6.0]
  def change
    create_table :system_locales do |t|
      t.references :system, foreign_key: true
      t.string :title, limit: 100
      t.integer :locale

      t.timestamps
    end
  end
end
