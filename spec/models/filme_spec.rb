require 'rails_helper'

RSpec.describe Filme, type: :model do
  # ============================================
  # ASSOCIAÇÕES
  # ============================================
  describe 'associações' do
    it { should belong_to(:usuario).optional }
    it { should have_many(:comentarios).dependent(:destroy) }
    it { should have_and_belong_to_many(:categorias) }
    it { should have_one_attached(:poster) }
  end

  # ============================================
  # VALIDAÇÕES
  # ============================================
  describe 'validações' do
    subject { build(:filme) }

    it { should validate_presence_of(:titulo) }
    it { should validate_numericality_of(:ano_lancamento).only_integer.is_greater_than(1800).allow_nil }
    it { should validate_numericality_of(:duracao_minutos).only_integer.is_greater_than(0).allow_nil }

    it 'aceita filme válido' do
      filme = build(:filme, titulo: 'Teste', ano_lancamento: 2020, duracao_minutos: 120)
      expect(filme).to be_valid
    end

    it 'rejeita filme sem título' do
      filme = build(:filme, titulo: nil)
      expect(filme).not_to be_valid
      expect(filme.errors[:titulo]).to be_present
    end

    it 'rejeita ano de lançamento negativo' do
      filme = build(:filme, ano_lancamento: -100)
      expect(filme).not_to be_valid
    end

    it 'rejeita duração negativa' do
      filme = build(:filme, duracao_minutos: -10)
      expect(filme).not_to be_valid
    end

    it 'aceita duração nula' do
      filme = build(:filme, duracao_minutos: nil)
      expect(filme).to be_valid
    end
  end

  # ============================================
  # SCOPES E MÉTODOS
  # ============================================
  describe 'ordenação' do
    it 'ordena por created_at desc por padrão' do
      filme1 = create(:filme, titulo: 'Primeiro')
      filme2 = create(:filme, titulo: 'Segundo')
      
      expect(Filme.all.to_a).to eq([filme2, filme1])
    end
  end

  describe 'relacionamento com categorias' do
    it 'pode ter múltiplas categorias' do
      filme = create(:filme)
      cat1 = create(:categoria, nome: 'Ação')
      cat2 = create(:categoria, nome: 'Drama')
      
      filme.categorias << [cat1, cat2]
      
      expect(filme.categorias.count).to eq(2)
      expect(filme.categorias).to include(cat1, cat2)
    end

    it 'pode não ter categorias' do
      filme = create(:filme)
      expect(filme.categorias).to be_empty
    end
  end

  describe 'relacionamento com comentários' do
    it 'destrói comentários ao ser deletado' do
      filme = create(:filme)
      comentario = create(:comentario, filme: filme)
      
      expect { filme.destroy }.to change { Comentario.count }.by(-1)
    end
  end

  describe 'relacionamento com usuário' do
    it 'mantém usuário mesmo se filme for deletado' do
      usuario = create(:usuario)
      filme = create(:filme, usuario: usuario)
      
      expect { filme.destroy }.not_to change { Usuario.count }
    end

    it 'permite filme sem usuário' do
      filme = create(:filme, usuario: nil)
      expect(filme).to be_valid
    end
  end
end
