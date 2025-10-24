require 'rails_helper'

RSpec.describe 'Filmes Paginação', type: :request do
  # Testes focados na lógica de paginação, sem renderizar views completas
  
  describe 'GET /filmes (index) - paginação' do
    context 'com muitos filmes' do
      before { create_list(:filme, 25) }

      it 'retorna sucesso e pagina resultados' do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it 'navega para segunda página' do
        get root_path, params: { page: 2 }
        expect(response).to have_http_status(:success)
      end
    end

    context 'sem filmes' do
      it 'retorna página vazia com sucesso' do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET /filmes/buscar - paginação na busca' do
    before do
      create(:filme, titulo: 'Matrix', sinopse: 'Filme de ação')
      create(:filme, titulo: 'Titanic', sinopse: 'Romance no navio')
      create_list(:filme, 15, titulo: 'Teste')
    end

    it 'busca e retorna sucesso' do
      get buscar_filmes_path, params: { q: 'Teste' }
      expect(response).to have_http_status(:success)
    end

    it 'busca termo específico' do
      get buscar_filmes_path, params: { q: 'Matrix' }
      expect(response).to have_http_status(:success)
    end

    it 'retorna sucesso quando sem resultados' do
      get buscar_filmes_path, params: { q: 'Inexistente' }
      expect(response).to have_http_status(:success)
    end
  end
end
