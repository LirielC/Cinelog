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

ActiveRecord::Schema[7.2].define(version: 2025_10_23_222934) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categorias", force: :cascade do |t|
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categorias_filmes", id: false, force: :cascade do |t|
    t.bigint "filme_id"
    t.bigint "categoria_id"
    t.index ["categoria_id"], name: "index_categorias_filmes_on_categoria_id"
    t.index ["filme_id"], name: "index_categorias_filmes_on_filme_id"
  end

  create_table "comentarios", force: :cascade do |t|
    t.text "conteudo", null: false
    t.string "nome_autor"
    t.bigint "usuario_id"
    t.bigint "filme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["filme_id"], name: "index_comentarios_on_filme_id"
    t.index ["usuario_id"], name: "index_comentarios_on_usuario_id"
  end

  create_table "filmes", force: :cascade do |t|
    t.string "titulo", null: false
    t.text "sinopse"
    t.integer "ano_lancamento"
    t.integer "duracao_minutos"
    t.string "diretor"
    t.bigint "usuario_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tmdb_id"
    t.index ["usuario_id"], name: "index_filmes_on_usuario_id"
  end

  create_table "filmes_tags", id: false, force: :cascade do |t|
    t.bigint "filme_id", null: false
    t.bigint "tag_id", null: false
    t.index ["filme_id", "tag_id"], name: "index_filmes_tags_on_filme_id_and_tag_id", unique: true
    t.index ["filme_id"], name: "index_filmes_tags_on_filme_id"
    t.index ["tag_id"], name: "index_filmes_tags_on_tag_id"
  end

  create_table "importacoes", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.string "arquivo"
    t.string "status"
    t.integer "total_linhas"
    t.integer "criados"
    t.integer "falhas"
    t.text "erros"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["usuario_id"], name: "index_importacoes_on_usuario_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_tags_on_nome", unique: true
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "nome", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "papel", default: "usuario", null: false
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categorias_filmes", "categorias"
  add_foreign_key "categorias_filmes", "filmes"
  add_foreign_key "comentarios", "filmes"
  add_foreign_key "comentarios", "usuarios"
  add_foreign_key "filmes", "usuarios"
  add_foreign_key "filmes_tags", "filmes"
  add_foreign_key "filmes_tags", "tags"
  add_foreign_key "importacoes", "usuarios"
end
