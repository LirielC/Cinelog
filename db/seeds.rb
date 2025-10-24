# ============================================
# SEEDS - Dados Iniciais do Cinelog
# ============================================
# Para popular o banco: rails db:seed
# Para resetar tudo: rails db:reset (apaga tudo e refaz)
# ============================================

puts "🌱 Iniciando seeds..."

# ============================================
# 1) CATEGORIAS
# ============================================
puts "\n📂 Criando categorias..."

categorias_nomes = [
  'Ação',
  'Aventura',
  'Animação',
  'Comédia',
  'Crime',
  'Documentário',
  'Drama',
  'Fantasia',
  'Ficção Científica',
  'Guerra',
  'Horror',
  'Musical',
  'Mistério',
  'Romance',
  'Suspense',
  'Terror',
  'Western',
  'Thriller',
  'Biografia',
  'Histórico',
  'Super-herói',
  'Policial',
  'Família',
  'Noir'
]

categorias_criadas = 0
categorias_existentes = 0

categorias_nomes.each do |nome|
  if Categoria.exists?(nome: nome)
    categorias_existentes += 1
    puts "  ⏭️  '#{nome}' já existe"
  else
    Categoria.create!(nome: nome)
    categorias_criadas += 1
    puts "  ✅ '#{nome}' criada"
  end
end

puts "\n📊 Categorias: #{categorias_criadas} criadas, #{categorias_existentes} já existiam"
puts "   Total: #{Categoria.count} categorias no banco"

# ============================================
# 2) USUÁRIOS
# ============================================
puts "\n👥 Criando usuários..."

# Usuário Admin
if Usuario.exists?(email: 'admin@cinelog.com')
  puts "  ⏭️  Admin já existe"
  admin = Usuario.find_by(email: 'admin@cinelog.com')
else
  admin = Usuario.create!(
    nome: 'Administrador',
    email: 'admin@cinelog.com',
    password: 'admin123',
    password_confirmation: 'admin123',
    papel: 'admin'
  )
  puts "  ✅ Admin criado: admin@cinelog.com / admin123"
end

# Usuário Moderador (opcional)
if Usuario.exists?(email: 'moderador@cinelog.com')
  puts "  ⏭️  Moderador já existe"
else
  Usuario.create!(
    nome: 'Moderador',
    email: 'moderador@cinelog.com',
    password: 'mod123',
    password_confirmation: 'mod123',
    papel: 'moderador'
  )
  puts "  ✅ Moderador criado: moderador@cinelog.com / mod123"
end

# Usuário normal (para testes)
if Usuario.exists?(email: 'usuario@cinelog.com')
  puts "  ⏭️  Usuário normal já existe"
else
  Usuario.create!(
    nome: 'João Silva',
    email: 'usuario@cinelog.com',
    password: 'senha123',
    password_confirmation: 'senha123',
    papel: 'usuario'
  )
  puts "  ✅ Usuário normal criado: usuario@cinelog.com / senha123"
end

puts "\n📊 Total de usuários: #{Usuario.count}"

# ============================================
# 3) FILMES DE EXEMPLO (OPCIONAL)
# ============================================
puts "\n🎬 Criando filmes de exemplo..."

filmes_exemplo = [
  {
    titulo: 'A Origem',
    sinopse: 'Dom Cobb é um ladrão com a rara habilidade de roubar segredos do inconsciente das pessoas, durante o sono.',
    ano_lancamento: 2010,
    duracao_minutos: 148,
    diretor: 'Christopher Nolan',
    categorias: ['Ficção Científica', 'Ação', 'Thriller']
  },
  {
    titulo: 'Interestelar',
    sinopse: 'Uma equipe de exploradores viaja através de um buraco de minhoca no espaço em uma tentativa de garantir a sobrevivência da humanidade.',
    ano_lancamento: 2014,
    duracao_minutos: 169,
    diretor: 'Christopher Nolan',
    categorias: ['Ficção Científica', 'Drama', 'Aventura']
  },
  {
    titulo: 'O Poderoso Chefão',
    sinopse: 'O patriarca de uma dinastia do crime organizado transfere o controle de seu império clandestino para seu filho relutante.',
    ano_lancamento: 1972,
    duracao_minutos: 175,
    diretor: 'Francis Ford Coppola',
    categorias: ['Crime', 'Drama']
  },
  {
    titulo: 'Pulp Fiction',
    sinopse: 'As vidas de dois assassinos da máfia, um boxeador, um gângster e sua esposa se entrelaçam em quatro contos de violência e redenção.',
    ano_lancamento: 1994,
    duracao_minutos: 154,
    diretor: 'Quentin Tarantino',
    categorias: ['Crime', 'Drama', 'Thriller']
  },
  {
    titulo: 'Matrix',
    sinopse: 'Um hacker descobre a verdade perturbadora sobre sua realidade e seu papel na guerra contra seus controladores.',
    ano_lancamento: 1999,
    duracao_minutos: 136,
    diretor: 'Lana Wachowski, Lilly Wachowski',
    categorias: ['Ficção Científica', 'Ação']
  }
]

filmes_criados = 0
filmes_existentes = 0

filmes_exemplo.each do |filme_data|
  if Filme.exists?(titulo: filme_data[:titulo])
    filmes_existentes += 1
    puts "  ⏭️  '#{filme_data[:titulo]}' já existe"
  else
    # Buscar categorias
    categorias = Categoria.where(nome: filme_data[:categorias])
    
    filme = Filme.create!(
      titulo: filme_data[:titulo],
      sinopse: filme_data[:sinopse],
      ano_lancamento: filme_data[:ano_lancamento],
      duracao_minutos: filme_data[:duracao_minutos],
      diretor: filme_data[:diretor],
      usuario: admin,
      categorias: categorias
    )
    
    filmes_criados += 1
    puts "  ✅ '#{filme_data[:titulo]}' criado"
  end
end

puts "\n📊 Filmes: #{filmes_criados} criados, #{filmes_existentes} já existiam"
puts "   Total: #{Filme.count} filmes no banco"

# ============================================
# RESUMO FINAL
# ============================================
puts "\n" + "="*50
puts "✅ SEEDS CONCLUÍDO!"
puts "="*50
puts "📊 Estatísticas:"
puts "   • Categorias: #{Categoria.count}"
puts "   • Usuários: #{Usuario.count}"
puts "   • Filmes: #{Filme.count}"
puts "\n🔑 Credenciais de acesso:"
puts "   • Admin: admin@cinelog.com / admin123"
puts "   • Moderador: moderador@cinelog.com / mod123"
puts "   • Usuário: usuario@cinelog.com / senha123"
puts "="*50
puts "🚀 Pronto para usar! Execute: rails server"
puts "="*50
