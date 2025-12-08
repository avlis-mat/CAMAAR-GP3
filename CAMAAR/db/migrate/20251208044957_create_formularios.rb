class CreateFormularios < ActiveRecord::Migration[8.0]
  def change
    create_table :formularios do |t|
      t.references :modelo, null: false, foreign_key: true
      t.references :materia, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: true
      t.string :titulo, null: false
      t.text :instrucoes
      t.date :data_inicio, null: false
      t.date :data_fim, null: false
      t.string :destinatario, null: false, default: 'todos'
      t.string :status, null: false, default: 'ativo'

      t.timestamps
    end

  add_index :formularios, :status
  add_index :formularios, [:data_inicio, :data_fim]
  end
end
