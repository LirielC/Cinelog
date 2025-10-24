namespace :categorias do
  desc "Popular categorias baseadas nos gêneros do TMDB"
  task popular: :environment do
    categorias = [
      'Ação',
      'Aventura',
      'Animação',
      'Comédia',
      'Crime',
      'Documentário',
      'Drama',
      'Família',
      'Fantasia',
      'História',
      'Terror',
      'Música',
      'Mistério',
      'Romance',
      'Ficção Científica',
      'Filme de TV',
      'Suspense',
      'Guerra',
      'Faroeste'
    ]
    
    categorias.each do |nome|
      categoria = Categoria.find_or_create_by(nome: nome)
      if categoria.persisted?
        puts "✓ Categoria '#{nome}' criada/encontrada"
      else
        puts "✗ Erro ao criar categoria '#{nome}': #{categoria.errors.full_messages.join(', ')}"
      end
    end
    
    puts "\n#{Categoria.count} categorias no total."
  end
  
  desc "Limpar todas as categorias (cuidado!)"
  task limpar: :environment do
    count = Categoria.count
    Categoria.destroy_all
    puts "#{count} categorias removidas."
  end
end
