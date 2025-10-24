class AddPapelToUsuarios < ActiveRecord::Migration[7.0]
  def change
    add_column :usuarios, :papel, :string, null: false, default: 'usuario'
  end
end
