class ChangeQuestaoOpcaoIdNullableInRespostas < ActiveRecord::Migration[8.0]
  def change
    change_column_null :respostas, :questao_opcao_id, true
  end
end
