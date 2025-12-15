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

ActiveRecord::Schema[8.0].define(version: 2025_12_14_231745) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "formularios", force: :cascade do |t|
    t.bigint "modelo_id", null: false
    t.bigint "materia_id", null: false
    t.bigint "usuario_id", null: false
    t.string "titulo", null: false
    t.text "instrucoes"
    t.date "data_inicio", null: false
    t.date "data_fim", null: false
    t.string "destinatario", default: "todos", null: false
    t.string "status", default: "ativo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "versao", default: 1, null: false
    t.integer "agrupamento"
    t.index ["data_inicio", "data_fim"], name: "index_formularios_on_data_inicio_and_data_fim"
    t.index ["materia_id"], name: "index_formularios_on_materia_id"
    t.index ["modelo_id"], name: "index_formularios_on_modelo_id"
    t.index ["status"], name: "index_formularios_on_status"
    t.index ["usuario_id"], name: "index_formularios_on_usuario_id"
  end

  create_table "materias", force: :cascade do |t|
    t.string "codigo", null: false
    t.string "codigo_turma", null: false
    t.string "nome", null: false
    t.string "departamento", null: false
    t.string "semestre", null: false
    t.string "professor"
    t.string "horario"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo", "codigo_turma", "semestre"], name: "idx_materia_turma_semestre", unique: true
    t.index ["codigo"], name: "index_materias_on_codigo"
    t.index ["departamento"], name: "index_materias_on_departamento"
    t.index ["semestre"], name: "index_materias_on_semestre"
  end

  create_table "modelos", force: :cascade do |t|
    t.string "nome", null: false
    t.text "descricao"
    t.bigint "usuario_id", null: false
    t.integer "versao", default: 1, null: false
    t.integer "agrupamento"
    t.string "status", default: "ativo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agrupamento", "versao"], name: "index_modelos_on_agrupamento_and_versao", unique: true
    t.index ["nome"], name: "index_modelos_on_nome"
    t.index ["status"], name: "index_modelos_on_status"
    t.index ["usuario_id"], name: "index_modelos_on_usuario_id"
  end

  create_table "questao_opcoes", force: :cascade do |t|
    t.bigint "questao_id", null: false
    t.text "texto", null: false
    t.boolean "is_correta", default: false
    t.integer "ordem", null: false
    t.integer "versao", default: 1, null: false
    t.integer "agrupamento"
    t.string "status", default: "ativo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agrupamento", "versao"], name: "index_questao_opcoes_on_agrupamento_and_versao", unique: true
    t.index ["questao_id", "ordem"], name: "index_questao_opcoes_on_questao_id_and_ordem"
    t.index ["questao_id"], name: "index_questao_opcoes_on_questao_id"
    t.index ["status"], name: "index_questao_opcoes_on_status"
  end

  create_table "questoes", force: :cascade do |t|
    t.bigint "modelo_id", null: false
    t.text "enunciado", null: false
    t.string "tipo", null: false
    t.integer "ordem", null: false
    t.integer "versao", default: 1, null: false
    t.integer "agrupamento"
    t.string "status", default: "ativo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agrupamento", "versao"], name: "index_questoes_on_agrupamento_and_versao", unique: true
    t.index ["modelo_id", "ordem"], name: "index_questoes_on_modelo_id_and_ordem"
    t.index ["modelo_id"], name: "index_questoes_on_modelo_id"
    t.index ["status"], name: "index_questoes_on_status"
  end

  create_table "respostas", force: :cascade do |t|
    t.bigint "formulario_id", null: false
    t.bigint "usuario_id", null: false
    t.bigint "questao_id", null: false
    t.bigint "questao_opcao_id"
    t.text "conteudo"
    t.datetime "respondido_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["formulario_id", "usuario_id", "questao_id"], name: "idx_resposta_unica", unique: true
    t.index ["formulario_id"], name: "index_respostas_on_formulario_id"
    t.index ["questao_id"], name: "index_respostas_on_questao_id"
    t.index ["questao_opcao_id"], name: "index_respostas_on_questao_opcao_id"
    t.index ["usuario_id"], name: "index_respostas_on_usuario_id"
  end

  create_table "token_senhas", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.string "token", null: false
    t.string "tipo", null: false
    t.datetime "expiracao", null: false
    t.boolean "usado", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "usado_em"
    t.index ["token"], name: "index_token_senhas_on_token", unique: true
    t.index ["usuario_id", "tipo", "usado"], name: "index_token_senhas_on_usuario_id_and_tipo_and_usado"
    t.index ["usuario_id"], name: "index_token_senhas_on_usuario_id"
  end

  create_table "usuario_materias", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.bigint "materia_id", null: false
    t.string "papel", default: "aluno", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["materia_id"], name: "index_usuario_materias_on_materia_id"
    t.index ["usuario_id", "materia_id"], name: "index_usuario_materias_on_usuario_id_and_materia_id", unique: true
    t.index ["usuario_id"], name: "index_usuario_materias_on_usuario_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "matricula", null: false
    t.string "nome", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "tipo", default: "aluno", null: false
    t.string "departamento"
    t.string "status", default: "pendente", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["matricula"], name: "index_usuarios_on_matricula", unique: true
    t.index ["status"], name: "index_usuarios_on_status"
    t.index ["tipo"], name: "index_usuarios_on_tipo"
  end

  add_foreign_key "formularios", "materias"
  add_foreign_key "formularios", "modelos"
  add_foreign_key "formularios", "usuarios"
  add_foreign_key "modelos", "usuarios"
  add_foreign_key "questao_opcoes", "questoes"
  add_foreign_key "questoes", "modelos"
  add_foreign_key "respostas", "formularios"
  add_foreign_key "respostas", "questao_opcoes"
  add_foreign_key "respostas", "questoes"
  add_foreign_key "respostas", "usuarios"
  add_foreign_key "token_senhas", "usuarios"
  add_foreign_key "usuario_materias", "materias"
  add_foreign_key "usuario_materias", "usuarios"
end
