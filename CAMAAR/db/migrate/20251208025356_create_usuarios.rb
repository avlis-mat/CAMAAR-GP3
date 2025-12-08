class CreateUsuarios < ActiveRecord::Migration[8.0]
  def change
    create_table :usuarios do |t|
      t.string :matricula, null:false
      t.string :nome, null:false
      t.string :email, null:false
      t.string :password_digest, null:false
      t.string :tipo, null:false, default: 'aluno'
      t.string :departamento
      t.string :status, null:false, default: 'pendente'

      t.timestamps
    end
    add_index :usuarios, :matricula, unique: true
    add_index :usuarios, :email, unique: true
    add_index :usuarios, :tipo
    add_index :usuarios, :status
  end
end
