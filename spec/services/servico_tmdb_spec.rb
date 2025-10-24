require 'rails_helper'

RSpec.describe ServicoTmdb do
  describe '.buscar_por_titulo' do
    let(:api_key) { '9725ed5f92d7e6eb79c5665132a83060' }
    
    before do
      allow(ENV).to receive(:[]).with('TMDB_API_KEY').and_return(api_key)
    end

    context 'quando API key não está configurada' do
      before do
        allow(ENV).to receive(:[]).with('TMDB_API_KEY').and_return(nil)
      end

      it 'retorna erro informando chave não configurada' do
        resultado = ServicoTmdb.buscar_por_titulo('Matrix')
        expect(resultado[:erro]).to eq('Chave TMDB não configurada')
      end
    end

    context 'com API key válida' do
      let(:search_results) { [{ 'id' => 603 }] }
      let(:movie_data) do
        {
          'overview' => 'Um hacker descobre a verdade',
          'release_date' => '1999-03-30',
          'runtime' => 136,
          'credits' => {
            'crew' => [
              { 'name' => 'Lana Wachowski', 'job' => 'Director' }
            ]
          }
        }
      end

      let(:mock_search_response) do
        double(
          success?: true,
          :[] => search_results
        ).tap do |resp|
          allow(resp).to receive(:[]).with('results').and_return(search_results)
        end
      end

      let(:mock_details_response) do
        double(
          success?: true
        ).tap do |resp|
          allow(resp).to receive(:[]).with('overview').and_return(movie_data['overview'])
          allow(resp).to receive(:[]).with('release_date').and_return(movie_data['release_date'])
          allow(resp).to receive(:[]).with('runtime').and_return(movie_data['runtime'])
          allow(resp).to receive(:[]).with('credits').and_return(movie_data['credits'])
        end
      end

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('TMDB_API_KEY').and_return(api_key)
        
        # Mock das chamadas HTTParty
        allow(ServicoTmdb).to receive(:get).with('/search/movie', any_args)
          .and_return(mock_search_response)
        
        allow(ServicoTmdb).to receive(:get).with(/\/movie\/\d+/, any_args)
          .and_return(mock_details_response)
      end

      it 'retorna dados do filme quando encontrado' do
        resultado = ServicoTmdb.buscar_por_titulo('Matrix')
        
        expect(resultado[:sinopse]).to eq('Um hacker descobre a verdade')
        expect(resultado[:ano_lancamento]).to eq(1999)
        expect(resultado[:duracao_minutos]).to eq(136)
        expect(resultado[:diretor]).to eq('Lana Wachowski')
        expect(resultado[:erro]).to be_nil
      end
    end

    context 'quando nenhum resultado é encontrado' do
      let(:empty_response) { { 'results' => [] } }

      before do
        allow(ServicoTmdb).to receive(:get)
          .with('/search/movie', query: { api_key: api_key, query: 'FilmeInexistente123' })
          .and_return(double(success?: true, '[]' => empty_response['results']))
      end

      it 'retorna erro informando que nenhum resultado foi encontrado' do
        resultado = ServicoTmdb.buscar_por_titulo('FilmeInexistente123')
        expect(resultado[:erro]).to eq('Nenhum resultado encontrado')
      end
    end

    context 'quando ocorre erro na API' do
      before do
        allow(ServicoTmdb).to receive(:get)
          .and_return(double(success?: false))
      end

      it 'retorna mensagem de erro apropriada' do
        resultado = ServicoTmdb.buscar_por_titulo('Matrix')
        expect(resultado[:erro]).to eq('Erro na busca TMDB')
      end
    end

    context 'quando ocorre exceção' do
      before do
        allow(ServicoTmdb).to receive(:get).and_raise(StandardError, 'Timeout')
      end

      it 'captura exceção e retorna erro' do
        resultado = ServicoTmdb.buscar_por_titulo('Matrix')
        expect(resultado[:erro]).to eq('Timeout')
      end
    end
  end
end
