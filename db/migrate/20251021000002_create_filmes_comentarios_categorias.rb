class CreateFilmesComentariosCategorias < ActiveRecord::Migration[7.0]
  def change
    create_table :filmes do |t|
      t.string :titulo, null: false
      t.text :sinopse
      t.integer :ano_lancamento
      t.integer :duracao_minutos
      t.string :diretor
      t.references :usuario, foreign_key: { to_table: :usuarios }

      t.timestamps
    end

    create_table :comentarios do |t|
      t.text :conteudo, null: false
      t.string :nome_autor
      t.references :usuario, foreign_key: { to_table: :usuarios }
      t.references :filme, foreign_key: true

      t.timestamps
    end

    create_table :categorias do |t|
      t.string :nome, null: false
      t.timestamps
    end

    create_table :categorias_filmes, id: false do |t|
      t.references :filme, foreign_key: true
      t.references :categoria, foreign_key: { to_table: :categorias }
    end
  end
end
