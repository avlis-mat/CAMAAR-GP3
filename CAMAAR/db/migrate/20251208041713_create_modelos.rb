class CreateModelos < ActiveRecord::Migration[8.0]
  def change
    create_table :modelos do |t|
      t.string :nome, null: false
      t.text :descricao
      t.references :usuario, null: false, foreign_key: true
      t.integer :versao, null: false, default: 1
      t.integer :agrupamento
      t.string :status, null: false, default: 'ativo'

      t.timestamps
    end

    add_index :modelos, [:agrupamento, :versao], unique: true
    add_index :modelos, :status
    add_index :modelos, :nome

  end
end
