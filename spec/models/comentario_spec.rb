require 'rails_helper'

RSpec.describe Comentario, type: :model do
  # ============================================
  # ASSOCIAÇÕES
  # ============================================
  describe 'associações' do
    it { should belong_to(:filme) }
    it { should belong_to(:usuario).optional }
  end

  # ============================================
  # VALIDAÇÕES
  # ============================================
  describe 'validações' do
    subject { build(:comentario) }

    it { should validate_presence_of(:conteudo) }
    it { should validate_length_of(:conteudo).is_at_least(3) }

    it 'aceita comentário válido' do
      comentario = build(:comentario, conteudo: 'Ótimo filme!')
      expect(comentario).to be_valid
    end

    it 'rejeita comentário sem conteúdo' do
      comentario = build(:comentario, conteudo: nil)
      expect(comentario).not_to be_valid
      expect(comentario.errors[:conteudo]).to be_present
    end

    it 'rejeita comentário muito curto' do
      comentario = build(:comentario, conteudo: 'Ok')
      expect(comentario).not_to be_valid
    end

    it 'aceita comentário com exatamente 3 caracteres' do
      comentario = build(:comentario, conteudo: 'Top')
      expect(comentario).to be_valid
    end
  end

  # ============================================
  # RELACIONAMENTOS
  # ============================================
  describe 'relacionamento com filme' do
    it 'requer um filme' do
      comentario = build(:comentario, filme: nil)
      expect(comentario).not_to be_valid
    end

    it 'é deletado quando filme é deletado' do
      filme = create(:filme)
      comentario = create(:comentario, filme: filme)
      
      expect { filme.destroy }.to change { Comentario.count }.by(-1)
    end
  end

  describe 'relacionamento com usuário' do
    it 'pode ter usuário' do
      usuario = create(:usuario)
      comentario = create(:comentario, usuario: usuario)
      
      expect(comentario.usuario).to eq(usuario)
    end

    it 'pode não ter usuário (comentário anônimo)' do
      comentario = create(:comentario, usuario: nil)
      expect(comentario).to be_valid
    end

    it 'mantém usuário se comentário for deletado' do
      usuario = create(:usuario)
      comentario = create(:comentario, usuario: usuario)
      
      expect { comentario.destroy }.not_to change { Usuario.count }
    end
  end

  # ============================================
  # CRIAÇÃO
  # ============================================
  describe 'criação' do
    it 'cria comentário com todos os atributos' do
      filme = create(:filme)
      usuario = create(:usuario)
      
      comentario = Comentario.create!(
        conteudo: 'Excelente filme!',
        filme: filme,
        usuario: usuario,
        nome_autor: usuario.nome
      )
      
      expect(comentario.persisted?).to be true
      expect(comentario.conteudo).to eq('Excelente filme!')
      expect(comentario.filme).to eq(filme)
      expect(comentario.usuario).to eq(usuario)
    end
  end
end
