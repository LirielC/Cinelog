require 'rails_helper'

RSpec.describe "Filmes", type: :request do
  let(:usuario) { create(:usuario) }
  let(:admin) { create(:usuario, :admin) }
  let(:categoria) { create(:categoria, nome: 'Ação') }
  
  let(:valid_attributes) do
    {
      titulo: 'Filme Teste',
      sinopse: 'Sinopse do filme teste',
      ano_lancamento: 2024,
      duracao_minutos: 120,
      diretor: 'Diretor Teste',
      categorias: [categoria.id]
    }
  end

  let(:invalid_attributes) do
    {
      titulo: '',
      sinopse: 'Sinopse',
      ano_lancamento: 1700, # Inválido (< 1800)
      duracao_minutos: -10, # Inválido (< 0)
      diretor: 'Diretor'
    }
  end

  # ============================================
  # INDEX - Listagem pública
  # ============================================
  describe "GET /filmes" do
    it 'renderiza a lista de filmes (visitante não autenticado)' do
      create_list(:filme, 3)
      get filmes_path
      expect(response).to have_http_status(:ok)
    end

    it 'renderiza a lista de filmes (usuário autenticado)' do
      sign_in usuario
      create_list(:filme, 3)
      get filmes_path
      expect(response).to have_http_status(:ok)
    end
  end

  # ============================================
  # SHOW - Visualização pública
  # ============================================
  describe "GET /filmes/:id" do
    let(:filme) { create(:filme, usuario: usuario) }

    it 'renderiza os detalhes do filme (visitante não autenticado)' do
      get filme_path(filme)
      expect(response).to have_http_status(:ok)
    end

    it 'renderiza os detalhes do filme (usuário autenticado)' do
      sign_in usuario
      get filme_path(filme)
      expect(response).to have_http_status(:ok)
    end
  end

  # ============================================
  # NEW - Requer autenticação
  # ============================================
  describe "GET /filmes/new" do
    context 'quando NÃO autenticado' do
      it 'redireciona para login' do
        get new_filme_path
        expect(response).to redirect_to(new_usuario_session_path)
      end
    end

    context 'quando autenticado' do
      it 'renderiza o formulário de novo filme' do
        sign_in usuario
        get new_filme_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ============================================
  # CREATE - Requer autenticação (TESTE OBRIGATÓRIO)
  # ============================================
  describe "POST /filmes" do
    context 'quando NÃO autenticado' do
      it 'redireciona para login' do
        post filmes_path, params: { filme: valid_attributes }
        expect(response).to redirect_to(new_usuario_session_path)
      end

      it 'não cria o filme no banco' do
        expect {
          post filmes_path, params: { filme: valid_attributes }
        }.not_to change(Filme, :count)
      end
    end

    context 'quando autenticado' do
      before { sign_in usuario }

      context 'com parâmetros válidos' do
        it 'cria um novo filme' do
          expect {
            post filmes_path, params: { filme: valid_attributes }
          }.to change(Filme, :count).by(1)
        end

        it 'associa o filme ao usuário autenticado' do
          post filmes_path, params: { filme: valid_attributes }
          expect(Filme.last.usuario).to eq(usuario)
        end

        it 'associa as categorias ao filme' do
          post filmes_path, params: { filme: valid_attributes }
          expect(Filme.last.categorias).to include(categoria)
        end

        it 'redireciona para o filme criado' do
          post filmes_path, params: { filme: valid_attributes }
          expect(response).to redirect_to(Filme.last)
        end

        it 'exibe mensagem de sucesso' do
          post filmes_path, params: { filme: valid_attributes }
          follow_redirect!
          expect(response.body).to include('Filme criado com sucesso')
        end
      end

      context 'com parâmetros inválidos' do
        it 'não cria o filme' do
          expect {
            post filmes_path, params: { filme: invalid_attributes }
          }.not_to change(Filme, :count)
        end

        it 're-renderiza o formulário' do
          post filmes_path, params: { filme: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'exibe mensagens de erro' do
          post filmes_path, params: { filme: invalid_attributes }
          expect(response.body).to include('erro')
        end
      end
    end
  end

  # ============================================
  # EDIT - Requer ser autor, admin ou moderador
  # ============================================
  describe "GET /filmes/:id/edit" do
    let(:filme) { create(:filme, usuario: usuario) }
    let(:outro_usuario) { create(:usuario) }

    context 'quando não autenticado' do
      it 'redireciona para login' do
        get edit_filme_path(filme)
        expect(response).to redirect_to(new_usuario_session_path)
      end
    end

    context 'quando é o autor' do
      it 'renderiza o formulário de edição' do
        sign_in usuario
        get edit_filme_path(filme)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'quando é admin' do
      it 'renderiza o formulário de edição' do
        sign_in admin
        get edit_filme_path(filme)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'quando é outro usuário (sem permissão)' do
      it 'redireciona ou retorna 403' do
        sign_in outro_usuario
        get edit_filme_path(filme)
        expect([302, 403]).to include(response.status)
      end
    end
  end

  # ============================================
  # UPDATE - Requer ser autor, admin ou moderador
  # ============================================
  describe "PATCH /filmes/:id" do
    let(:filme) { create(:filme, usuario: usuario, titulo: 'Título Original') }
    let(:outro_usuario) { create(:usuario) }
    let(:new_attributes) { { titulo: 'Título Atualizado' } }

    context 'quando não autenticado' do
      it 'redireciona para login' do
        patch filme_path(filme), params: { filme: new_attributes }
        expect(response).to redirect_to(new_usuario_session_path)
      end
    end

    context 'quando é o autor' do
      before { sign_in usuario }

      it 'atualiza o filme' do
        patch filme_path(filme), params: { filme: new_attributes }
        filme.reload
        expect(filme.titulo).to eq('Título Atualizado')
      end

      it 'redireciona para o filme atualizado' do
        patch filme_path(filme), params: { filme: new_attributes }
        expect(response).to redirect_to(filme)
      end
    end

    context 'quando é admin' do
      it 'atualiza o filme' do
        sign_in admin
        patch filme_path(filme), params: { filme: new_attributes }
        filme.reload
        expect(filme.titulo).to eq('Título Atualizado')
      end
    end

    context 'quando é outro usuário (sem permissão)' do
      it 'não atualiza o filme' do
        sign_in outro_usuario
        patch filme_path(filme), params: { filme: new_attributes }
        filme.reload
        expect(filme.titulo).to eq('Título Original')
      end
    end
  end

  # ============================================
  # DESTROY - Requer ser autor ou admin
  # ============================================
  describe "DELETE /filmes/:id" do
    let!(:filme) { create(:filme, usuario: usuario) }
    let(:moderador) { create(:usuario, :moderador) }
    let(:outro_usuario) { create(:usuario) }

    context 'quando não autenticado' do
      it 'redireciona para login' do
        delete filme_path(filme)
        expect(response).to redirect_to(new_usuario_session_path)
      end

      it 'não deleta o filme' do
        expect {
          delete filme_path(filme)
        }.not_to change(Filme, :count)
      end
    end

    context 'quando é o autor' do
      it 'deleta o filme' do
        sign_in usuario
        expect {
          delete filme_path(filme)
        }.to change(Filme, :count).by(-1)
      end

      it 'redireciona para a listagem' do
        sign_in usuario
        delete filme_path(filme)
        expect(response.location).to include('/filmes')
      end
    end

    context 'quando é admin' do
      it 'deleta o filme' do
        sign_in admin
        expect {
          delete filme_path(filme)
        }.to change(Filme, :count).by(-1)
      end
    end

    context 'quando é moderador (SEM permissão delete)' do
      it 'não deleta o filme' do
        sign_in moderador
        expect {
          delete filme_path(filme)
        }.not_to change(Filme, :count)
      end
    end

    context 'quando é outro usuário (sem permissão)' do
      it 'não deleta o filme' do
        sign_in outro_usuario
        expect {
          delete filme_path(filme)
        }.not_to change(Filme, :count)
      end
    end
  end
end
