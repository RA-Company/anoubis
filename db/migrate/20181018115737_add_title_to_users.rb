class AddTitleToUsers < ActiveRecord::Migration[6.0]
  def up
    execute "ALTER TABLE users ADD title VARCHAR(250) AS (CONCAT(name, ' ', surname, ' (', email, ')'));"
    execute "ALTER TABLE users ADD fi VARCHAR(250) AS (CONCAT(name, ' ', surname));"
  end
  def down
    execute "ALTER TABLE users DROP fi;"
    execute "ALTER TABLE users DROP title;"
  end
end
