require 'rails_helper'

RSpec.describe ImportacaoJob, type: :job do
  let(:usuario) { create(:usuario) }
  let(:importacao) { create(:importacao, usuario: usuario, status: Importacao::STATUS_PENDENTE) }
  
  describe '#perform' do
    context 'com CSV válido' do
      let(:csv_content) do
        <<~CSV
          titulo,sinopse,ano_lancamento,duracao_minutos,diretor,categorias
          Matrix,Um hacker descobre a realidade,1999,136,Wachowski,Ação,Ficção
          Interestelar,Exploradores atravessam,2014,169,Nolan,Ficção,Drama
        CSV
      end
      
      before do
        File.write(importacao.arquivo, csv_content)
      end
      
      after do
        File.delete(importacao.arquivo) if File.exist?(importacao.arquivo)
      end

      it 'processa o CSV e cria filmes' do
        expect {
          ImportacaoJob.perform_now(importacao.id)
        }.to change(Filme, :count).by(2)
      end

      it 'atualiza o status para concluído' do
        ImportacaoJob.perform_now(importacao.id)
        importacao.reload
        
        expect(importacao.status).to eq(Importacao::STATUS_CONCLUIDO)
      end

      it 'registra estatísticas corretas' do
        ImportacaoJob.perform_now(importacao.id)
        importacao.reload
        
        expect(importacao.total_linhas).to eq(2)
        expect(importacao.criados).to eq(2)
        expect(importacao.falhas).to eq(0)
      end

      it 'cria categorias automaticamente' do
        expect {
          ImportacaoJob.perform_now(importacao.id)
        }.to change(Categoria, :count).by_at_least(2)
      end

      it 'remove o arquivo após processar' do
        caminho = importacao.arquivo
        ImportacaoJob.perform_now(importacao.id)
        
        expect(File.exist?(caminho)).to be false
      end
    end

    context 'com CSV com linhas inválidas' do
      let(:csv_content) do
        <<~CSV
          titulo,sinopse,ano_lancamento,duracao_minutos,diretor,categorias
          ,Filme sem título,2020,120,Diretor,Drama
          Filme Válido,Sinopse válida,2021,100,Diretor,Ação
        CSV
      end
      
      before do
        File.write(importacao.arquivo, csv_content)
      end
      
      after do
        File.delete(importacao.arquivo) if File.exist?(importacao.arquivo)
      end

      it 'processa apenas filmes válidos' do
        expect {
          ImportacaoJob.perform_now(importacao.id)
        }.to change(Filme, :count).by(1)
      end

      it 'registra erros das linhas inválidas' do
        ImportacaoJob.perform_now(importacao.id)
        importacao.reload
        
        expect(importacao.erros).to include('Linha 1')
        expect(importacao.erros).to include('Título')
      end

      it 'marca como concluído mesmo com falhas parciais' do
        ImportacaoJob.perform_now(importacao.id)
        importacao.reload
        
        expect(importacao.status).to eq(Importacao::STATUS_CONCLUIDO)
        expect(importacao.criados).to eq(1)
        expect(importacao.falhas).to eq(1)
      end
    end

    context 'com cabeçalhos inválidos' do
      let(:csv_content) do
        <<~CSV
          nome,descricao,ano
          Matrix,Filme de ação,1999
        CSV
      end
      
      before do
        File.write(importacao.arquivo, csv_content)
      end
      
      after do
        File.delete(importacao.arquivo) if File.exist?(importacao.arquivo)
      end

      it 'não cria nenhum filme' do
        expect {
          ImportacaoJob.perform_now(importacao.id)
        }.not_to change(Filme, :count)
      end

      it 'marca como falha' do
        ImportacaoJob.perform_now(importacao.id)
        importacao.reload
        
        expect(importacao.status).to eq(Importacao::STATUS_FALHA)
        expect(importacao.erros).to include('Cabeçalhos inválidos')
      end
    end

    context 'com arquivo inexistente' do
      before do
        importacao.update(arquivo: '/caminho/inexistente.csv')
      end

      it 'marca como falha' do
        ImportacaoJob.perform_now(importacao.id)
        importacao.reload
        
        expect(importacao.status).to eq(Importacao::STATUS_FALHA)
        expect(importacao.erros).to include('Arquivo não encontrado')
      end

      it 'não cria filmes' do
        expect {
          ImportacaoJob.perform_now(importacao.id)
        }.not_to change(Filme, :count)
      end
    end

    context 'com CSV malformado' do
      let(:csv_content) { "titulo,sinopse\n\"Filme sem fechar aspas,teste\ninvalido" }
      
      before do
        File.write(importacao.arquivo, csv_content)
      end
      
      after do
        File.delete(importacao.arquivo) if File.exist?(importacao.arquivo)
      end

      it 'marca como falha e registra erro' do
        ImportacaoJob.perform_now(importacao.id)
        importacao.reload
        
        expect(importacao.status).to eq(Importacao::STATUS_FALHA)
        expect(importacao.erros).to include('malformado')
      end
    end

    context 'com erro inesperado' do
      before do
        allow(CSV).to receive(:foreach).and_raise(StandardError, 'Erro simulado')
        File.write(importacao.arquivo, 'titulo\nTeste')
      end
      
      after do
        File.delete(importacao.arquivo) if File.exist?(importacao.arquivo)
      end

      it 'captura erro e marca como falha' do
        ImportacaoJob.perform_now(importacao.id)
        importacao.reload
        
        expect(importacao.status).to eq(Importacao::STATUS_FALHA)
        expect(importacao.erros).to include('Erro inesperado')
      end
    end
  end

  describe 'integração com Filme e Categoria' do
    let(:csv_content) do
      <<~CSV
        titulo,sinopse,ano_lancamento,duracao_minutos,diretor,categorias
        Filme 1,Sinopse 1,2020,120,Diretor 1,Ação
        Filme 2,Sinopse 2,2021,90,Diretor 2,"Ação,Drama"
      CSV
    end
    
    before do
      File.write(importacao.arquivo, csv_content)
    end
    
    after do
      File.delete(importacao.arquivo) if File.exist?(importacao.arquivo)
    end

    it 'associa usuário aos filmes criados' do
      ImportacaoJob.perform_now(importacao.id)
      
      filmes = Filme.last(2)
      expect(filmes.all? { |f| f.usuario == usuario }).to be true
    end

    it 'não duplica categorias existentes' do
      acao = Categoria.create!(nome: 'Ação')
      
      expect {
        ImportacaoJob.perform_now(importacao.id)
      }.to change(Categoria, :count).by(1) # Apenas Drama é nova
      
      # Verificar que a categoria Ação existente foi reusada
      expect(Categoria.where(nome: 'Ação').count).to eq(1)
      expect(Categoria.find_by(nome: 'Ação').id).to eq(acao.id)
    end

    it 'associa múltiplas categorias corretamente' do
      ImportacaoJob.perform_now(importacao.id)
      
      filme = Filme.find_by(titulo: 'Filme 2')
      expect(filme.categorias.map(&:nome)).to contain_exactly('Ação', 'Drama')
    end
  end
end
