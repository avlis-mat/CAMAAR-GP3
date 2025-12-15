class AddUsadoEmToTokenSenhas < ActiveRecord::Migration[8.0]
  def change
    add_column :token_senhas, :usado_em, :datetime
  end
end
