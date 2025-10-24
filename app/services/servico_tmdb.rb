class ServicoTmdb
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'

  def self.buscar_por_titulo(titulo, idioma = 'pt-BR')
    api_key = ENV['TMDB_API_KEY']
    return { erro: 'Chave TMDB não configurada' } unless api_key.present?

    resp = get('/search/movie', query: { api_key: api_key, query: titulo, language: idioma })
    return { erro: 'Erro na busca TMDB' } unless resp.success?

    primeiro = resp['results']&.first
    return { erro: 'Nenhum resultado encontrado' } unless primeiro

    detalhes = get("/movie/#{primeiro['id']}", query: { api_key: api_key, append_to_response: 'credits', language: idioma })
    return { erro: 'Erro ao obter detalhes' } unless detalhes.success?

    diretor = detalhes['credits']['crew']&.find { |c| c['job'] == 'Director' }&.dig('name')
    
    # Extrair gêneros (categorias) do TMDB
    generos_tmdb = detalhes['genres']&.map { |g| g['name'] } || []

    {
      titulo: detalhes['title'],
      sinopse: detalhes['overview'],
      ano_lancamento: detalhes['release_date']&.split('-')&.first&.to_i,
      duracao_minutos: detalhes['runtime'],
      diretor: diretor,
      tmdb_id: primeiro['id'],
      generos: generos_tmdb
    }
  rescue StandardError => e
    { erro: e.message }
  end
  
  # Buscar dados traduzidos de um filme específico pelo ID TMDB
  def self.buscar_traducao(tmdb_id, idioma = 'en')
    api_key = ENV['TMDB_API_KEY']
    return nil unless api_key.present? && tmdb_id.present?

    detalhes = get("/movie/#{tmdb_id}", query: { api_key: api_key, language: idioma })
    return nil unless detalhes.success?

    {
      titulo: detalhes['title'],
      sinopse: detalhes['overview']
    }
  rescue StandardError => e
    nil
  end
end
