require 'rails_helper'

RSpec.describe Categoria, type: :model do
  # ============================================
  # ASSOCIAÇÕES
  # ============================================
  describe 'associações' do
    it { should have_and_belong_to_many(:filmes) }
  end

  # ============================================
  # VALIDAÇÕES
  # ============================================
  describe 'validações' do
    subject { build(:categoria) }

    it { should validate_presence_of(:nome) }
    it { should validate_uniqueness_of(:nome) }

    it 'aceita categoria válida' do
      categoria = build(:categoria, nome: 'Drama')
      expect(categoria).to be_valid
    end

    it 'rejeita categoria sem nome' do
      categoria = build(:categoria, nome: nil)
      expect(categoria).not_to be_valid
      expect(categoria.errors[:nome]).to be_present
    end

    it 'rejeita categoria com nome duplicado' do
      create(:categoria, nome: 'Ação')
      categoria_duplicada = build(:categoria, nome: 'Ação')
      
      expect(categoria_duplicada).not_to be_valid
      expect(categoria_duplicada.errors[:nome]).to be_present
    end
  end

  # ============================================
  # RELACIONAMENTOS
  # ============================================
  describe 'relacionamento com filmes' do
    it 'pode ter múltiplos filmes' do
      categoria = create(:categoria, nome: 'Ação')
      filme1 = create(:filme)
      filme2 = create(:filme)
      
      categoria.filmes << [filme1, filme2]
      
      expect(categoria.filmes.count).to eq(2)
      expect(categoria.filmes).to include(filme1, filme2)
    end

    it 'pode não ter filmes' do
      categoria = create(:categoria)
      expect(categoria.filmes).to be_empty
    end

    it 'mantém categoria quando filme é deletado' do
      categoria = create(:categoria)
      filme = create(:filme)
      categoria.filmes << filme
      
      expect { filme.destroy }.not_to change { Categoria.count }
    end
  end
end
