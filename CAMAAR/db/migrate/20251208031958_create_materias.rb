class CreateMaterias < ActiveRecord::Migration[8.0]
  def change
    create_table :materias do |t|
      t.string :codigo, null: false
      t.string :codigo_turma, null: false
      t.string :nome, null: false
      t.string :departamento, null: false
      t.string :semestre, null: false
      t.string :professor
      t.string :horario

      t.timestamps
    end
    
    add_index :materias, [:codigo, :codigo_turma, :semestre], 
              unique: true, 
              name: 'idx_materia_turma_semestre'
    add_index :materias, :codigo
    add_index :materias, :departamento
    add_index :materias, :semestre

  end
end
