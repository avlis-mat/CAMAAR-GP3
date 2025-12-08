class CreateTokenSenhas < ActiveRecord::Migration[8.0]
  def change
    create_table :token_senhas do |t|
      t.references :usuario, null: false, foreign_key: true
      t.string :token, null: false
      t.string :tipo, null: false
      t.datetime :expiracao, null: false
      t.boolean :usado, null: false, default: false

      t.timestamps
    end

    add_index :token_senhas, :token, unique: true
    add_index :token_senhas, [:usuario_id, :tipo, :usado]
  end
end
