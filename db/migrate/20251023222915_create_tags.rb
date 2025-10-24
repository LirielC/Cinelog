class CreateTags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string :nome, null: false

      t.timestamps
    end
    
    add_index :tags, :nome, unique: true
  end
end
