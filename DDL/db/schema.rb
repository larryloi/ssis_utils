# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20191017065140) do

  create_table "arc_actions", force: :cascade do |t|
    t.string   "name",        limit: 45,  null: false
    t.string   "description", limit: 128, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "arc_actions", ["name"], name: "uk1_arc_actions_name", unique: true

  create_table "arc_databases", force: :cascade do |t|
    t.string   "name",       limit: 128, null: false
    t.integer  "state",      limit: 4,   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "arc_databases", ["name"], name: "uk1_arc_database_name", unique: true

  create_table "arc_logs", force: :cascade do |t|
    t.string   "job_id",            limit: 36,   null: false
    t.string   "arc_database_name", limit: 128,  null: false
    t.string   "schema_name",       limit: 128,  null: false
    t.string   "arc_table_name",    limit: 128,  null: false
    t.string   "arc_action",        limit: 45,   null: false
    t.string   "state",             limit: 45,   null: false
    t.datetime "data_start_at",                  null: false
    t.datetime "data_end_at",                    null: false
    t.datetime "logged_at",                      null: false
    t.string   "message",           limit: 4000
  end

  add_index "arc_logs", ["data_start_at", "data_end_at"], name: "idx2_data_start_at_data_end_at"
  add_index "arc_logs", ["job_id"], name: "idx1_job_id"
  add_index "arc_logs", ["logged_at"], name: "idx3_logged_at"

  create_table "arc_tables", force: :cascade do |t|
    t.integer  "arc_database_id",            limit: 4,   null: false
    t.string   "schema_name",                limit: 128, null: false
    t.string   "name",                       limit: 128, null: false
    t.integer  "state",                      limit: 4,   null: false
    t.string   "date_key",                   limit: 128, null: false
    t.integer  "backup_batch_interval_hour", limit: 4,   null: false
    t.integer  "backup_delay_interval_hour", limit: 4,   null: false
    t.datetime "backup_data_start_at",                   null: false
    t.datetime "backup_data_end_at",                     null: false
    t.integer  "delete_batch_interval_hour", limit: 4
    t.integer  "delete_delay_interval_day",  limit: 4
    t.datetime "delete_data_start_at"
    t.datetime "delete_data_end_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "arc_tables", ["arc_database_id", "schema_name", "name"], name: "uk1_arc_table_arc_database_id_schema_name_name", unique: true

  create_table "etl_job_schedules", force: :cascade do |t|
    t.integer  "etl_job_id",             limit: 4, null: false
    t.integer  "enabled",                limit: 1, null: false
    t.integer  "freq_type",              limit: 4, null: false
    t.integer  "freq_interval",          limit: 4, null: false
    t.integer  "freq_subday_type",       limit: 4, null: false
    t.integer  "freq_subday_interval",   limit: 4, null: false
    t.integer  "freq_relative_interval", limit: 4, null: false
    t.integer  "freq_recurrence_factor", limit: 4, null: false
    t.integer  "active_start_date",      limit: 4, null: false
    t.integer  "active_end_date",        limit: 4, null: false
    t.integer  "active_start_time",      limit: 4, null: false
    t.integer  "active_end_time",        limit: 4, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "etl_job_schedules", ["etl_job_id"], name: "uk1_etl_job_schedules_etl_job_id", unique: true

  create_table "etl_job_step_params", force: :cascade do |t|
    t.integer  "etl_job_step_id", limit: 4,   null: false
    t.string   "parameter",       limit: 256, null: false
    t.string   "value",           limit: 256, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "etl_job_step_params", ["etl_job_step_id", "parameter"], name: "uk1_etl_job_step_params_etl_job_step_id_parameter", unique: true

  create_table "etl_job_steps", force: :cascade do |t|
    t.integer  "etl_job_id",           limit: 4,          null: false
    t.string   "name",                 limit: 128,        null: false
    t.integer  "cmdexec_success_code", limit: 4,          null: false
    t.integer  "on_success_action",    limit: 1,          null: false
    t.integer  "on_success_step_id",   limit: 4,          null: false
    t.integer  "on_fail_action",       limit: 1,          null: false
    t.integer  "on_fail_step_id",      limit: 4,          null: false
    t.integer  "retry_attempts",       limit: 4,          null: false
    t.integer  "retry_interval",       limit: 4,          null: false
    t.integer  "os_run_priority",      limit: 4,          null: false
    t.string   "subsystem",            limit: 40,         null: false
    t.text     "command",              limit: 2147483647
    t.string   "database_name",        limit: 128,        null: false
    t.integer  "flags",                limit: 4,          null: false
    t.string   "ssis_package",         limit: 260
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "proxy_name",           limit: 128
  end

  add_index "etl_job_steps", ["etl_job_id", "name"], name: "uk1_etl_job_steps_etl_job_id_name", unique: true

  create_table "etl_jobs", force: :cascade do |t|
    t.string   "name",                  limit: 128, null: false
    t.integer  "enabled",               limit: 1,   null: false
    t.integer  "notify_level_eventlog", limit: 4,   null: false
    t.integer  "notify_level_email",    limit: 4,   null: false
    t.integer  "notify_level_netsend",  limit: 4,   null: false
    t.integer  "notify_level_page",     limit: 4,   null: false
    t.integer  "delete_level",          limit: 4,   null: false
    t.string   "description",           limit: 512, null: false
    t.string   "category_name",         limit: 128, null: false
    t.string   "owner_login_name",      limit: 128, null: false
    t.string   "ssis_folder",           limit: 128, null: false
    t.string   "ssis_project",          limit: 128, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "etl_jobs", ["name"], name: "uk1_etl_jobs_name", unique: true
  add_index "etl_jobs", ["ssis_folder", "ssis_project"], name: "idx1_etl_jobs_ssis_folder_ssis_project"

  create_table "system_parameters", force: :cascade do |t|
    t.string   "feature",     limit: 45,  null: false
    t.string   "parameter",   limit: 128, null: false
    t.string   "value",       limit: 512, null: false
    t.string   "description", limit: 512, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "system_parameters", ["feature", "parameter"], name: "uk1_system_parameters_feature_parameter", unique: true

  create_table "util_cmds", force: :cascade do |t|
    t.string   "name",        limit: 85,         null: false
    t.string   "description", limit: 512,        null: false
    t.ntext    "cmd_text",    limit: 2147483647, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "util_cmds", ["name"], name: "uk_util_cmds_name", unique: true

  add_foreign_key "arc_tables", "arc_databases", name: "fk1_arc_tables_arc_database_id", on_update: :cascade, on_delete: :cascade
end
