class CreateFilmesTags < ActiveRecord::Migration[7.2]
  def change
    create_table :filmes_tags, id: false do |t|
      t.references :filme, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
    end
    
    add_index :filmes_tags, [:filme_id, :tag_id], unique: true
  end
end
