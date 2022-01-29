class CreateGroupLocales < ActiveRecord::Migration[6.0]
  def change
    create_table :group_locales do |t|
      t.references :group, foreign_key: true
      t.string :title, limit: 100
      t.integer :locale

      t.timestamps
    end
  end
end
