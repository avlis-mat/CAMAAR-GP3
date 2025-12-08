class CreateUsuarioMaterias < ActiveRecord::Migration[8.0]
  def change
    create_table :usuario_materias do |t|
      t.references :usuario, null: false, foreign_key: true
      t.references :materia, null: false, foreign_key: true
      t.string :papel, null: false, default: 'aluno'

      t.timestamps
    end

    add_index :usuario_materias, [:usuario_id, :materia_id], unique: true
  end
end
