class CreateRespostas < ActiveRecord::Migration[8.0]
  def change
    create_table :respostas do |t|
      t.references :formulario, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: true
      t.references :questao, null: false, foreign_key: true
      t.references :questao_opcao, null: false, foreign_key: true
      t.text :conteudo
      t.datetime :respondido_em

      t.timestamps
    end

    add_index :respostas, [:formulario_id, :usuario_id, :questao_id], 
              unique: true,
              name: 'idx_resposta_unica'
  end
end
