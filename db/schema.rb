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

ActiveRecord::Schema.define(version: 20141231182255) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "curator_codes", force: true do |t|
    t.integer  "no_of_codes"
    t.integer  "code_frequency"
    t.datetime "last_code_time"
    t.text     "status"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "curator_codes", ["user_id"], name: "index_curator_codes_on_user_id", using: :btree

  create_table "invitation_codes", force: true do |t|
    t.string   "code_text"
    t.integer  "invitation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitation_codes", ["invitation_id"], name: "index_invitation_codes_on_invitation_id", using: :btree

  create_table "invitations", force: true do |t|
    t.string   "invitee_email"
    t.string   "invitee_name"
    t.datetime "invitation_sent_at"
    t.text     "status"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["user_id"], name: "index_invitations_on_user_id", using: :btree

  create_table "missions", force: true do |t|
    t.string   "title"
    t.string   "brief"
    t.string   "shared_motivation"
    t.string   "build_intent"
    t.datetime "from_date"
    t.datetime "to_date"
    t.text     "time"
    t.text     "place"
    t.boolean  "status"
    t.boolean  "is_authorized"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  create_table "roles", force: true do |t|
    t.string "name"
  end

  create_table "skills", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_missions", force: true do |t|
    t.text     "invitation_status"
    t.datetime "invitation_time"
    t.integer  "user_id"
    t.integer  "mission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_missions", ["mission_id"], name: "index_user_missions_on_mission_id", using: :btree
  add_index "user_missions", ["user_id"], name: "index_user_missions_on_user_id", using: :btree

  create_table "user_ratings", force: true do |t|
    t.integer  "rating"
    t.string   "notes"
    t.integer  "user_skill_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_ratings", ["user_skill_id"], name: "index_user_ratings_on_user_skill_id", using: :btree

  create_table "user_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_roles", ["role_id"], name: "index_user_roles_on_role_id", using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "user_skills", force: true do |t|
    t.text     "time_spent"
    t.text     "company"
    t.string   "work_ref"
    t.text     "founded"
    t.integer  "user_id"
    t.integer  "skill_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_skills", ["skill_id"], name: "index_user_skills_on_skill_id", using: :btree
  add_index "user_skills", ["user_id"], name: "index_user_skills_on_user_id", using: :btree

  create_table "user_tags", force: true do |t|
    t.integer  "user_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_tags", ["tag_id"], name: "index_user_tags_on_tag_id", using: :btree
  add_index "user_tags", ["user_id"], name: "index_user_tags_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "profile_pic"
    t.text     "city"
    t.string   "working_at"
    t.string   "languages"
    t.string   "passions"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
