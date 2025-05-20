# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_04_01_000006) do
  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "alert_rules", force: :cascade do |t|
    t.string "name", null: false
    t.string "metric_type", null: false
    t.string "operator", null: false
    t.float "threshold", null: false
    t.string "severity", null: false
    t.string "duration", null: false
    t.text "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metric_type"], name: "index_alert_rules_on_metric_type"
    t.index ["name"], name: "index_alert_rules_on_name"
  end

  create_table "automated_responses", force: :cascade do |t|
    t.integer "alert_rule_id", null: false
    t.string "action_type", null: false
    t.string "target_service"
    t.string "command"
    t.string "cooldown_period", null: false
    t.text "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_rule_id"], name: "index_automated_responses_on_alert_rule_id"
  end

  create_table "host_configurations", force: :cascade do |t|
    t.integer "remote_host_id", null: false
    t.string "configurable_type", null: false
    t.integer "configurable_id", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["configurable_type", "configurable_id"], name: "index_host_configurations_on_configurable"
    t.index ["remote_host_id", "configurable_type", "configurable_id"], name: "index_host_configurations_uniqueness", unique: true
    t.index ["remote_host_id"], name: "index_host_configurations_on_remote_host_id"
  end

  create_table "remote_hosts", force: :cascade do |t|
    t.string "hostname", null: false
    t.integer "port", default: 22, null: false
    t.string "description"
    t.string "username", null: false
    t.boolean "active", default: true
    t.string "status"
    t.datetime "last_seen_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hostname"], name: "index_remote_hosts_on_hostname", unique: true
  end

  create_table "telegraf_cpu_configs", force: :cascade do |t|
    t.string "name", null: false
    t.string "interval", null: false
    t.text "description"
    t.boolean "active", default: true
    t.integer "alert_rule_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_rule_id"], name: "index_telegraf_cpu_configs_on_alert_rule_id"
    t.index ["name"], name: "index_telegraf_cpu_configs_on_name", unique: true
  end

  create_table "telegraf_ram_configs", force: :cascade do |t|
    t.string "name", null: false
    t.string "interval", null: false
    t.text "description"
    t.boolean "active", default: true
    t.integer "alert_rule_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_rule_id"], name: "index_telegraf_ram_configs_on_alert_rule_id"
    t.index ["name"], name: "index_telegraf_ram_configs_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "automated_responses", "alert_rules"
  add_foreign_key "host_configurations", "remote_hosts"
  add_foreign_key "telegraf_cpu_configs", "alert_rules"
  add_foreign_key "telegraf_ram_configs", "alert_rules"
end
