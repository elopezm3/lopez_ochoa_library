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

ActiveRecord::Schema[7.2].define(version: 2025_12_26_224657) do
  create_table "autores", force: :cascade do |t|
    t.string "nombre"
    t.string "apellido"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "copias", force: :cascade do |t|
    t.integer "libro_id", null: false
    t.string "prestamo"
    t.date "fecha"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["libro_id"], name: "index_copias_on_libro_id"
  end

  create_table "libros", force: :cascade do |t|
    t.string "titulo"
    t.integer "autor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["autor_id"], name: "index_libros_on_autor_id"
  end

  add_foreign_key "copias", "libros"
  add_foreign_key "libros", "autores"
end
