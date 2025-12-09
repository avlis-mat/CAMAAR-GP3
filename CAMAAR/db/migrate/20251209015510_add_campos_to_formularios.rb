class AddCamposToFormularios < ActiveRecord::Migration[8.0]
  def change
    add_column :formularios, :versao, :integer, null: false, default: 1
    add_column :formularios, :agrupamento, :integer
  end
end
