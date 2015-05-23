# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110429003112) do

  create_table "assignments", :force => true do |t|
    t.integer "person_id", :limit => 8, :null => false
    t.integer "sess_id",   :limit => 8, :null => false
    t.string  "role",      :limit => 1, :null => false
    t.integer "certainty", :limit => 2
  end

  add_index "assignments", ["id"], :name => "id", :unique => true
  add_index "assignments", ["person_id"], :name => "person_id"
  add_index "assignments", ["sess_id"], :name => "sess_id"

  create_table "categories", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "catprefs", :force => true do |t|
    t.integer "category_id", :null => false
    t.integer "person_id",   :null => false
    t.integer "value",       :null => false
  end

  add_index "catprefs", ["category_id"], :name => "index_catprefs_on_category_id"
  add_index "catprefs", ["person_id"], :name => "index_catprefs_on_person_id"

  create_table "classrooms", :force => true do |t|
    t.string  "shortname", :limit => 20
    t.string  "name",                    :null => false
    t.integer "mingrade",  :limit => 2,  :null => false
  end

  add_index "classrooms", ["id"], :name => "id", :unique => true

  create_table "configurations", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histories", :force => true do |t|
    t.integer "project_id", :limit => 8, :null => false
    t.string  "who",                     :null => false
    t.string  "role",       :limit => 1, :null => false
    t.integer "year",                    :null => false
  end

  add_index "histories", ["id"], :name => "id", :unique => true
  add_index "histories", ["project_id"], :name => "project_id"

  create_table "locations", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "locations", ["id"], :name => "id", :unique => true

  create_table "notes", :force => true do |t|
    t.integer   "year"
    t.timestamp "updated_at", :null => false
    t.text      "text"
  end

  add_index "notes", ["id"], :name => "id", :unique => true

  create_table "people", :force => true do |t|
    t.string  "name",                                      :null => false
    t.integer "classroom_id", :limit => 8,                 :null => false
    t.integer "grade",        :limit => 2,                 :null => false
    t.text    "notes"
    t.string  "password",                  :default => "", :null => false
    t.string  "email"
  end

  add_index "people", ["classroom_id"], :name => "classroom_id"
  add_index "people", ["id"], :name => "id", :unique => true

  create_table "projects", :force => true do |t|
    t.string  "abbrev",        :limit => 8
    t.string  "shortname",     :limit => 20
    t.string  "name",                                          :null => false
    t.text    "description"
    t.text    "notes"
    t.integer "mingrade",      :limit => 2
    t.integer "maxgrade",      :limit => 2
    t.integer "capacity",      :limit => 2
    t.boolean "isreal",                      :default => true, :null => false
    t.text    "review"
    t.boolean "thisyear",                    :default => true, :null => false
    t.text    "schedulenotes"
  end

  add_index "projects", ["id"], :name => "id", :unique => true

  create_table "requests", :force => true do |t|
    t.integer "person_id",  :limit => 8,                  :null => false
    t.integer "project_id", :limit => 8,                  :null => false
    t.integer "rank",       :limit => 2,                  :null => false
    t.string  "role",       :limit => 1, :default => "P", :null => false
  end

  add_index "requests", ["id"], :name => "id", :unique => true
  add_index "requests", ["person_id"], :name => "person_id"
  add_index "requests", ["project_id"], :name => "project_id"

  create_table "sesses", :force => true do |t|
    t.integer "project_id",  :limit => 8, :null => false
    t.integer "location_id", :limit => 8
    t.boolean "confirmed"
  end

  add_index "sesses", ["id"], :name => "id", :unique => true
  add_index "sesses", ["project_id"], :name => "project_id"

  create_table "sesses_timeslots", :id => false, :force => true do |t|
    t.integer "sess_id",     :limit => 8, :null => false
    t.integer "timeslot_id", :limit => 8, :null => false
  end

  add_index "sesses_timeslots", ["timeslot_id"], :name => "timeslot_id"

  create_table "timeslots", :force => true do |t|
    t.string "day",   :limit => 8
    t.string "start", :limit => 8
    t.string "stop",  :limit => 8
  end

  add_index "timeslots", ["id"], :name => "id", :unique => true

end
