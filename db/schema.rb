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

ActiveRecord::Schema[7.2].define(version: 2025_03_30_103941) do
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
    t.string "metric_type", null: false
    t.string "operator", null: false
    t.float "threshold", null: false
    t.string "severity", null: false
    t.string "duration", null: false
    t.string "description"
    t.boolean "active", default: true
    t.string "host"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metric_type", "host"], name: "index_alert_rules_on_metric_type_and_host"
  end

  create_table "automated_responses", force: :cascade do |t|
    t.integer "alert_rule_id", null: false
    t.string "action_type", null: false
    t.string "target_service", null: false
    t.string "cooldown_period", null: false
    t.text "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_rule_id"], name: "index_automated_responses_on_alert_rule_id"
  end

  create_table "response_executions", force: :cascade do |t|
    t.integer "automated_response_id", null: false
    t.string "status"
    t.text "result"
    t.datetime "executed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["automated_response_id"], name: "index_response_executions_on_automated_response_id"
    t.index ["executed_at"], name: "index_response_executions_on_executed_at"
  end

  create_table "telegraf_cpu_configs", force: :cascade do |t|
    t.string "description"
    t.string "interval", default: "10s"
    t.boolean "active", default: true
    t.boolean "percpu", default: true
    t.boolean "totalcpu", default: true
    t.boolean "collect_cpu_time", default: false
    t.boolean "report_active", default: false
    t.text "remote_hosts"
    t.boolean "use_ssh"
    t.string "ssh_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "telegraf_memory_configs", force: :cascade do |t|
    t.string "description"
    t.string "interval", default: "10s"
    t.boolean "active", default: true
    t.boolean "swap_memory", default: true
    t.boolean "platform_memory", default: true
    t.text "remote_hosts"
    t.boolean "use_ssh"
    t.string "ssh_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  add_foreign_key "response_executions", "automated_responses"
end
