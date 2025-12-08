class CreateQuestaoOpcoes < ActiveRecord::Migration[8.0]
  def change
    create_table :questao_opcoes do |t|
      t.references :questao, null: false, foreign_key: true
      t.text :texto, null: false
      t.boolean :is_correta, default: false
      t.integer :ordem, null: false
      t.integer :versao, null: false, default: 1
      t.integer :agrupamento
      t.string :status, null: false, default: 'ativo'

      t.timestamps
    end

  add_index :questao_opcoes, [:agrupamento, :versao], unique: true
  add_index :questao_opcoes, [:questao_id, :ordem]
  add_index :questao_opcoes, :status
  end
end
