# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_12_25_062339) do

  create_table "group_locales", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "group_id"
    t.string "title", limit: 100
    t.integer "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_locales_on_group_id"
  end

  create_table "group_menus", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "menu_id", default: 0
    t.bigint "group_id", default: 0
    t.integer "access"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_menus_on_group_id"
    t.index ["menu_id", "group_id"], name: "index_group_menus_on_menu_id_and_group_id", unique: true
    t.index ["menu_id"], name: "index_group_menus_on_menu_id"
  end

  create_table "groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "ident", limit: 50
    t.bigint "system_id"
    t.string "full_ident", limit: 70
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["full_ident"], name: "index_groups_on_full_ident", unique: true
    t.index ["ident", "system_id"], name: "index_groups_on_ident_and_system_id", unique: true
    t.index ["system_id"], name: "index_groups_on_system_id"
  end

  create_table "menu_locales", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "menu_id"
    t.integer "locale", default: 0, null: false
    t.string "title", limit: 200
    t.string "page_title", limit: 200
    t.string "short_title", limit: 200
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id", "locale"], name: "index_menu_locales_on_menu_id_and_locale", unique: true
    t.index ["menu_id"], name: "index_menu_locales_on_menu_id"
  end

  create_table "menus", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "mode", limit: 200
    t.string "action", limit: 50
    t.bigint "menu_id"
    t.integer "tab", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.integer "page_size", default: 0, null: false
    t.integer "state", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_menus_on_menu_id"
    t.index ["mode"], name: "index_menus_on_mode", unique: true
    t.index ["tab"], name: "index_menus_on_tab"
  end

  create_table "system_locales", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "system_id"
    t.string "title", limit: 100
    t.integer "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_id"], name: "index_system_locales_on_system_id"
  end

  create_table "system_menus", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "system_id"
    t.bigint "menu_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_system_menus_on_menu_id"
    t.index ["system_id", "menu_id"], name: "index_system_menus_on_system_id_and_menu_id", unique: true
    t.index ["system_id"], name: "index_system_menus_on_system_id"
  end

  create_table "systems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "ident", limit: 15
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ident"], name: "index_systems_on_ident", unique: true
  end

  create_table "tenant_systems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "tenant_id"
    t.bigint "system_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_id"], name: "index_tenant_systems_on_system_id"
    t.index ["tenant_id", "system_id"], name: "index_tenant_systems_on_tenant_id_and_system_id", unique: true
    t.index ["tenant_id"], name: "index_tenant_systems_on_tenant_id"
  end

  create_table "tenants", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", limit: 100
    t.string "ident", limit: 10
    t.integer "state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ident"], name: "index_tenants_on_ident", unique: true
    t.index ["title"], name: "index_tenants_on_title", unique: true
  end

  create_table "user_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_user_groups_on_group_id"
    t.index ["user_id", "group_id"], name: "index_user_groups_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "login", limit: 65, null: false
    t.string "email", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.string "surname", limit: 100, null: false
    t.string "timezone", limit: 30, null: false
    t.integer "timeout", default: 3600, null: false
    t.string "phone", limit: 30
    t.string "password_digest", limit: 60, null: false
    t.string "auth_key", limit: 32
    t.string "recover_key", limit: 32
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id"
    t.binary "uuid_bin", limit: 16
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "title", type: :string, limit: 250, as: "concat(`name`,' ',`surname`,' (',`email`,')')"
    t.index ["email", "tenant_id"], name: "index_users_on_email_and_tenant_id", unique: true
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
    t.index ["uuid_bin"], name: "index_users_on_uuid_bin", unique: true
  end

  add_foreign_key "group_locales", "groups"
  add_foreign_key "group_menus", "groups"
  add_foreign_key "group_menus", "menus"
  add_foreign_key "groups", "systems"
  add_foreign_key "menu_locales", "menus"
  add_foreign_key "menus", "menus"
  add_foreign_key "system_locales", "systems"
  add_foreign_key "system_menus", "menus"
  add_foreign_key "system_menus", "systems"
  add_foreign_key "tenant_systems", "systems"
  add_foreign_key "tenant_systems", "tenants"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
  add_foreign_key "users", "tenants"
end
