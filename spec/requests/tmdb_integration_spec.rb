require 'rails_helper'

RSpec.describe 'TMDB Integration', type: :request do
  describe 'POST /tmdb_lookup' do
    let(:valid_titulo) { 'Matrix' }
    
    before do
      # Permite chamadas originais ao ENV e sobrescreve apenas TMDB_API_KEY
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('TMDB_API_KEY').and_return('test_key')
    end

    context 'quando filme é encontrado' do
      let(:mock_resultado) do
        {
          sinopse: 'Um hacker descobre a verdade',
          ano_lancamento: 1999,
          duracao_minutos: 136,
          diretor: 'Wachowski'
        }
      end

      before do
        allow(ServicoTmdb).to receive(:buscar_por_titulo)
          .with(valid_titulo)
          .and_return(mock_resultado)
      end

      it 'retorna dados do filme em JSON' do
        post '/tmdb_lookup', params: { titulo: valid_titulo }
        
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(json_response[:sinopse]).to eq('Um hacker descobre a verdade')
        expect(json_response[:ano_lancamento]).to eq(1999)
        expect(json_response[:duracao_minutos]).to eq(136)
        expect(json_response[:diretor]).to eq('Wachowski')
      end
    end

    context 'quando ocorre erro na busca' do
      before do
        allow(ServicoTmdb).to receive(:buscar_por_titulo)
          .and_return({ erro: 'Nenhum resultado encontrado' })
      end

      it 'retorna erro em JSON com status bad_request' do
        post '/tmdb_lookup', params: { titulo: 'FilmeInexistente' }
        
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(json_response[:erro]).to eq('Nenhum resultado encontrado')
      end
    end

    context 'quando API key não está configurada' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('TMDB_API_KEY').and_return(nil)
        allow(ServicoTmdb).to receive(:buscar_por_titulo)
          .and_return({ erro: 'Chave TMDB não configurada' })
      end

      it 'retorna erro informando chave não configurada' do
        post '/tmdb_lookup', params: { titulo: valid_titulo }
        
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(json_response[:erro]).to eq('Chave TMDB não configurada')
      end
    end
  end
end
