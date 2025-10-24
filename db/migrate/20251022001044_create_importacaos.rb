class CreateImportacaos < ActiveRecord::Migration[7.2]
  def change
    create_table :importacoes do |t|
      t.references :usuario, null: false, foreign_key: true
      t.string :arquivo
      t.string :status
      t.integer :total_linhas
      t.integer :criados
      t.integer :falhas
      t.text :erros

      t.timestamps
    end
  end
end
