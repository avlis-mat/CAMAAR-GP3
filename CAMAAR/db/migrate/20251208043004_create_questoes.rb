class CreateQuestoes < ActiveRecord::Migration[8.0]
  def change
    create_table :questoes do |t|
      t.references :modelo, null: false, foreign_key: true
      t.text :enunciado, null: false
      t.string :tipo, null: false
      t.integer :ordem, null: false
      t.integer :versao, null: false, default: 1
      t.integer :agrupamento
      t.string :status, null: false, default: 'ativo'

      t.timestamps
    end

    add_index :questoes, [:agrupamento, :versao], unique: true
    add_index :questoes, [:modelo_id, :ordem]
    add_index :questoes, :status
  end
end
