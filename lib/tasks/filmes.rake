namespace :filmes do
  desc "Atualiza os filmes existentes com o TMDB ID"
  task atualizar_tmdb_ids: :environment do
    puts "Atualizando TMDB IDs dos filmes..."
    
    Filme.where(tmdb_id: nil).find_each do |filme|
      print "Processando: #{filme.titulo}..."
      
      begin
        resultado = ServicoTmdb.buscar_por_titulo(filme.titulo, 'pt-BR')
        
        if resultado[:erro]
          puts " ❌ Erro: #{resultado[:erro]}"
        elsif resultado[:tmdb_id]
          filme.update_column(:tmdb_id, resultado[:tmdb_id])
          puts " ✅ ID: #{resultado[:tmdb_id]}"
        else
          puts " ⚠️  Não encontrado"
        end
        
        # Aguardar um pouco para não sobrecarregar a API
        sleep(0.3)
      rescue => e
        puts " ❌ Exceção: #{e.message}"
      end
    end
    
    puts "\nConcluído! #{Filme.where.not(tmdb_id: nil).count} filmes com TMDB ID."
  end
end
