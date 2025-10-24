class AddTmdbIdToFilmes < ActiveRecord::Migration[7.2]
  def change
    add_column :filmes, :tmdb_id, :integer
  end
end
